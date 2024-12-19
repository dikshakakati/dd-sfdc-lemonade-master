/**
 * @author Deloitte
 * @date 11/17/2022
 * @description Test class for BriefItemsService class.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class BriefItemsServiceImplTest {
    private static final String BANNER_TYPE_HOMEPAGE = 'Home Page';
    private static final String CAMPAIGN_HALLOWEEN_DEALS = 'Halloween Deals';
    private static final String CAMPAIGN_THANKSGIVING = 'Thanksgiving Offers';
    private static final String CATEGORIES_SPONSORED_PRODUCTS_PACKAGE = 'CnG Categories';
    private static final String COLLECTIONS_SPONSORED_PRODUCTS_PACKAGE = 'CnG Collections';
    private static final String CRM_CAMPAIGN_TYPE_EMAIL = 'Email';
    private static final String DOUBLEDASH_SPONSORED_PRODUCTS_PACKAGE = 'CnG DoubleDash';
    private static final String NOT_APPLICABLE = 'N/A';
    private static final String PAYMENT_PROTOCOL_INVOICING = 'Invoicing';
    private static final String PICKLIST_VALUE_NO = 'No';
    private static final String PRICING_TYPE_FLAT_FEE = 'Flat Fee';
    private static final String STATUS_WAITINGFORINPUTS = 'Waiting for Inputs';
    private static final String STATUS_CAMPAIGN_BUILDING = 'Campaign Building';
    private static final String SEARCH_SPONSORED_PRODUCTS_PACKAGE = 'CnG Search';
    private static final String SPONSORED_PRODUCTS = 'Sponsored Products';
    private static final String BLANK_VALUE = '';
    private static final String SPONSORSHIPS = 'Sponsorships';
    private static final String BUY_ITEM_GET_OFF = 'Buy Item, Get $X or Y% Off';

    @isTest
    private static void testWhenQuoteLineItemsAndBriefsArePassedThenBriefItemsAreCreated() {
        Id marketplacePromotionQuoteLineItem = fflib_IDGenerator.generate(
            SBQQ__QuoteLine__c.SObjectType
        );
        Id advertisementQuoteLineItem = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id advertisementQliForSponsorships = fflib_IDGenerator.generate(
            SBQQ__QuoteLine__c.SObjectType
        );
        Id advertisementParentQliForSponsorships = fflib_IDGenerator.generate(
            SBQQ__QuoteLine__c.SObjectType
        );
        Id contractSignedQuote = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id marketplacePromotionBrief = fflib_IDGenerator.generate(Brief__c.SObjectType);
        Id advertisementBrief = fflib_IDGenerator.generate(Brief__c.SObjectType);
        Id advertisementSponsorshipsPackageBrief = fflib_IDGenerator.generate(Brief__c.SObjectType);
        Id marketplacePromotionQuoteBriefRelationship = fflib_IDGenerator.generate(
            Quote_Brief_Relationship__c.SObjectType
        );
        Id advertisementQuoteBriefRelationship = fflib_IDGenerator.generate(
            Quote_Brief_Relationship__c.SObjectType
        );
        Id advertisementSponsorshipsQuoteBriefRelationship = fflib_IDGenerator.generate(
            Quote_Brief_Relationship__c.SObjectType
        );

        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>{
            (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
                .setField(SBQQ__QuoteLine__c.Id, marketplacePromotionQuoteLineItem)
                .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, contractSignedQuote)
                .setField(SBQQ__QuoteLine__c.Campaign_Name__c, CAMPAIGN_HALLOWEEN_DEALS)
                .setField(SBQQ__QuoteLine__c.Has_Brief_Item__c, false)
                .toSObject(),
            (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
                .setField(SBQQ__QuoteLine__c.Id, advertisementQuoteLineItem)
                .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, contractSignedQuote)
                .setField(SBQQ__QuoteLine__c.Campaign_Name__c, CAMPAIGN_THANKSGIVING)
                .setField(SBQQ__QuoteLine__c.Has_Brief_Item__c, false)
                .toSObject(),
            (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
                .setField(SBQQ__QuoteLine__c.Id, advertisementQliForSponsorships)
                .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, contractSignedQuote)
                .setField(SBQQ__QuoteLine__c.Has_Brief_Item__c, false)
                .setField(SBQQ__QuoteLine__c.Package__c, SPONSORSHIPS)
                .setParent(
                    'SBQQ__RequiredBy__r',
                    new Fake(SBQQ__QuoteLine__c.class)
                        .setField(
                            SBQQ__QuoteLine__c.SBQQ__RequiredBy__r.Campaign_Name__c,
                            'Sponsorships Campaign'
                        )
                        .setField(
                            SBQQ__QuoteLine__c.SBQQ__RequiredBy__r.Id,
                            advertisementParentQliForSponsorships
                        )
                )
                .toSObject()
        };
        List<Quote_Brief_Relationship__c> quoteBriefRelationships = new List<Quote_Brief_Relationship__c>{
            (Quote_Brief_Relationship__c) new Fake(Quote_Brief_Relationship__c.class)
                .setField(
                    Quote_Brief_Relationship__c.Id,
                    marketplacePromotionQuoteBriefRelationship
                )
                .setField(Quote_Brief_Relationship__c.Quote__c, contractSignedQuote)
                .setField(Quote_Brief_Relationship__c.Brief__c, marketplacePromotionBrief)
                .setField(
                    Quote_Brief_Relationship__c.Campaign_of_Brief__c,
                    CAMPAIGN_HALLOWEEN_DEALS
                )
                .toSObject(),
            (Quote_Brief_Relationship__c) new Fake(Quote_Brief_Relationship__c.class)
                .setField(Quote_Brief_Relationship__c.Id, advertisementQuoteBriefRelationship)
                .setField(Quote_Brief_Relationship__c.Quote__c, contractSignedQuote)
                .setField(Quote_Brief_Relationship__c.Brief__c, advertisementBrief)
                .setField(Quote_Brief_Relationship__c.Campaign_of_Brief__c, CAMPAIGN_THANKSGIVING)
                .toSObject(),
            (Quote_Brief_Relationship__c) new Fake(Quote_Brief_Relationship__c.class)
                .setField(
                    Quote_Brief_Relationship__c.Id,
                    advertisementSponsorshipsQuoteBriefRelationship
                )
                .setField(Quote_Brief_Relationship__c.Quote__c, contractSignedQuote)
                .setField(
                    Quote_Brief_Relationship__c.Brief__c,
                    advertisementSponsorshipsPackageBrief
                )
                .setField(Quote_Brief_Relationship__c.Campaign_of_Brief__c, 'Sponsorships Campaign')
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        BriefItemsService.generateBriefItemsByQuoteLineItems(
            quoteLineItems,
            quoteBriefRelationships
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Brief_Item__c.Brief__c => marketplacePromotionBrief,
                        Brief_Item__c.Quote_Line__c => marketplacePromotionQuoteLineItem
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Brief_Item__c.Brief__c => advertisementBrief,
                        Brief_Item__c.Quote_Line__c => advertisementQuoteLineItem
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Brief_Item__c.Brief__c => advertisementSponsorshipsPackageBrief,
                        Brief_Item__c.Quote_Line__c => advertisementQliForSponsorships
                    }
                )
            );
        System.assertEquals(
            true,
            quoteLineItems[0].Has_Brief_Item__c,
            'Failed to update Quote Line Item.'
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    @isTest
    private static void testWhenQuoteLineItemsAndBriefsArePassedThenBriefItemsAreCreatedWithAutopopulatedValues() {
        Id advertisementQuoteLineItem = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id contractSignedQuote = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id marketplacePromotionBrief = fflib_IDGenerator.generate(Brief__c.SObjectType);
        Id advertisementBrief = fflib_IDGenerator.generate(Brief__c.SObjectType);
        Id marketplacePromotionQuoteBriefRelationship = fflib_IDGenerator.generate(
            Quote_Brief_Relationship__c.SObjectType
        );
        Id advertisementQuoteBriefRelationship = fflib_IDGenerator.generate(
            Quote_Brief_Relationship__c.SObjectType
        );

        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>{
            (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
                .setField(SBQQ__QuoteLine__c.Id, advertisementQuoteLineItem)
                .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, contractSignedQuote)
                .setField(SBQQ__QuoteLine__c.CurrencyIsoCode, 'USD')
                .setField(SBQQ__QuoteLine__c.Campaign_Name__c, CAMPAIGN_THANKSGIVING)
                .setField(SBQQ__QuoteLine__c.SBQQ__ProductName__c, 'CRM')
                .toSObject()
        };
        List<Quote_Brief_Relationship__c> quoteBriefRelationships = new List<Quote_Brief_Relationship__c>{
            (Quote_Brief_Relationship__c) new Fake(Quote_Brief_Relationship__c.class)
                .setField(
                    Quote_Brief_Relationship__c.Id,
                    marketplacePromotionQuoteBriefRelationship
                )
                .setField(Quote_Brief_Relationship__c.Quote__c, contractSignedQuote)
                .setField(Quote_Brief_Relationship__c.Brief__c, marketplacePromotionBrief)
                .setField(
                    Quote_Brief_Relationship__c.Campaign_of_Brief__c,
                    CAMPAIGN_HALLOWEEN_DEALS
                )
                .toSObject(),
            (Quote_Brief_Relationship__c) new Fake(Quote_Brief_Relationship__c.class)
                .setField(Quote_Brief_Relationship__c.Id, advertisementQuoteBriefRelationship)
                .setField(Quote_Brief_Relationship__c.Quote__c, contractSignedQuote)
                .setField(Quote_Brief_Relationship__c.Brief__c, advertisementBrief)
                .setField(Quote_Brief_Relationship__c.Campaign_of_Brief__c, CAMPAIGN_THANKSGIVING)
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        BriefItemsService.generateBriefItemsByQuoteLineItems(
            quoteLineItems,
            quoteBriefRelationships
        );
    }
    /*Brief_Item__c marketplaceBriefItem = new Brief_Item__c(
            Brief__c = advertisementBrief,
            CurrencyIsoCode = null,
            Status__c = 'Waiting for Inputs',
            Number_of_Campaign_Setup_Errors_Found__c = 0,
            Opportunity_Owner__c = null,
            Holdout_Audience_Experiment__c = 'No',
            Evergreen_Ongoing_Promo__c = 'Yes',
            Store_Page_Banner_Included_for_Promo__c = 'No',
            Signed_Contract__c = null,
            Netsuite_ID__c = null,
            Affinity_Target_Audience__c = null,
            Applicable_DoorDash_Order_Types__c = null,
            Auto_Bidding__c = null,
            Average_Daily_Budget__c = null,
            Banner_Dates__c = null,
            Banner_Types__c = null,
            Bid__c = null,
            Brands__c = null,
            Brief_Routing__c = null,
            Budget__c = null,
            Budget_Period__c = null,
            Campaign_Name__c = 'Thanksgiving Offers',
            Custom_Creative_Required__c = null,
            Daily_Budget_Cap__c = null,
            Max_Number_of_Redemptions_per_Cx__c = null,
            Max_Number_of_Redemptions_per_Cart__c = null,
            Minimum_required_spend_against_brand__c = null,
            Items_to_receive_discount__c = null,
            //Categories_Bid__c = null,
            //Collections_Bid__c = null,
            Day_Time_of_Week__c = null,
            Discount_Percentage_for_Consumer__c = null,
            Discounted_Delivery_Fee__c = null,
            End_Date__c = null,
            Flat_Discount_for_Consumer__c = null,
            Incremental_Marketing_Fee_Redemption__c = null,
            Sponsored_Listing_Terms__c = null,
            Max_Discount_for_Consumer__c = null,
            Max_Redemption_Cap__c = null,
            Menu_Item_Minimum_Quantity__c = null,
            Minimum_Banner_Fee__c = null,
            Minimum_Cart_Subtotal__c = null,
            Offer_Detailed_Description__c = null,
            Package__c = null,
            Payment_Protocol__c = null,
            Percent_of_Fee_to_Invoice_Merchant__c = null,
            Pricing_Type__c = null,
            Product__c = 'CRM',
            Quote_Line__c = advertisementQuoteLineItem,
            //Search_Bid__c = null,
            Setup_Fee_Currency__c = null,
            Start_Date__c = null,
            Targeting__c = null,
            Term_Specific_Bidding__c = null,
            UPCs__c = null,
            Unit_Price__c = null,
            CRM_Campaign_Type__c = null,
            Item_Description_Details__c = null,
            Item_Name__c = null,
            Item_Type__c = null,
            Influencer_Campaign_Platforms__c = null,
            Allow_Rewards_to_Expire_after_60_Days__c = null,
            Program_Type__c = null,
            Required_Spend_Threshold__c = null,
            Required_Visits_Threshold__c = null,
            Minimum_Spend_Per_Order__c = null,
            Reward_Type__c = null,
            Reward__c = null,
            Free_Item_Name_s__c = null,
            Co_funding_Cap_for_DPEI__c = null,
            Offsite_Platform__c = null,
			Offsite_Banner_Type__c = null,
			Offsite_Cx_Targeting_Type__c = null,
			Service_Fee_As_Percent_Budget__c = null,
			Data_Fee_As_Percent_Budget__c = null
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerNew(marketplaceBriefItem);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }*/

    /**
     * @description It is used to test if Brief Items for Sponsored Product package is created
     * with auto-populated values from Sponsored Product Quote Line Items.
     */
    @isTest
    private static void testWhenSponsoredProductsQuoteLineItemsAndBriefsPassedThenBriefItemsCreatedWithAutoPopulatedValues() {
        Id marketplacePromotionQuoteLineItem = fflib_IDGenerator.generate(
            SBQQ__QuoteLine__c.SObjectType
        );
        Id searchQuoteLineItem = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id categoriesQuoteLineItem = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id doubleDashQuoteLineItem = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id colectionsQuoteLineItem = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id contractSignedQuote = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id marketplacePromotionBrief = fflib_IDGenerator.generate(Brief__c.SObjectType);
        Id marketplacePromotionQuoteBriefRelationship = fflib_IDGenerator.generate(
            Quote_Brief_Relationship__c.SObjectType
        );
        Fake parentQuoteLineInstane = new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, marketplacePromotionQuoteLineItem)
            .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, contractSignedQuote)
            .setField(SBQQ__QuoteLine__c.Campaign_Name__c, CAMPAIGN_HALLOWEEN_DEALS)
            .setField(SBQQ__QuoteLine__c.Start_Date__c, System.today() - 1)
            .setField(SBQQ__QuoteLine__c.End_Date__c, System.today())
            .setField(SBQQ__QuoteLine__c.Marketing_Flat_Fee__c, 0)
            .setField(SBQQ__QuoteLine__c.Payment_Method__c, PAYMENT_PROTOCOL_INVOICING)
            .setField(SBQQ__QuoteLine__c.Pricing_Type__c, PRICING_TYPE_FLAT_FEE)
            .setField(SBQQ__QuoteLine__c.Banner_Dates__c, NOT_APPLICABLE)
            .setField(SBQQ__QuoteLine__c.Banner_Type__c, BANNER_TYPE_HOMEPAGE)
            .setField(SBQQ__QuoteLine__c.User_Communication_Type__c, CRM_CAMPAIGN_TYPE_EMAIL)
            .setField(SBQQ__QuoteLine__c.SBQQ__ProductName__c, SPONSORED_PRODUCTS)
            .setField(SBQQ__QuoteLine__c.Has_Brief_Item__c, false);

        Fake childSearchQuoteLineInstance = new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, searchQuoteLineItem)
            .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, contractSignedQuote)
            .setField(SBQQ__QuoteLine__c.Start_Date__c, System.today() - 4)
            .setField(SBQQ__QuoteLine__c.End_Date__c, System.today() + 1)
            .setField(SBQQ__QuoteLine__c.CurrencyIsoCode, 'USD')
            .setField(SBQQ__QuoteLine__c.Campaign_Name__c, CAMPAIGN_THANKSGIVING)
            .setField(SBQQ__QuoteLine__c.SBQQ__ProductName__c, SEARCH_SPONSORED_PRODUCTS_PACKAGE)
            .setField(SBQQ__QuoteLine__c.SBQQ__RequiredBy__c, marketplacePromotionQuoteLineItem)
            .setField(SBQQ__QuoteLine__c.Bid__c, 5)
            .setParent('SBQQ__RequiredBy__r', parentQuoteLineInstane);

        Fake childDoubleDashQuoteLineInstance = new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, doubleDashQuoteLineItem)
            .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, contractSignedQuote)
            .setField(SBQQ__QuoteLine__c.Start_Date__c, System.today() - 4)
            .setField(SBQQ__QuoteLine__c.End_Date__c, System.today() + 1)
            .setField(SBQQ__QuoteLine__c.CurrencyIsoCode, 'USD')
            .setField(SBQQ__QuoteLine__c.Campaign_Name__c, CAMPAIGN_THANKSGIVING)
            .setField(
                SBQQ__QuoteLine__c.SBQQ__ProductName__c,
                DOUBLEDASH_SPONSORED_PRODUCTS_PACKAGE
            )
            .setField(SBQQ__QuoteLine__c.SBQQ__RequiredBy__c, marketplacePromotionQuoteLineItem)
            .setField(SBQQ__QuoteLine__c.Bid__c, 6)
            .setParent('SBQQ__RequiredBy__r', parentQuoteLineInstane);

        Fake childCategoriesQuoteLineInstance = new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, categoriesQuoteLineItem)
            .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, contractSignedQuote)
            .setField(SBQQ__QuoteLine__c.Start_Date__c, System.today() - 4)
            .setField(SBQQ__QuoteLine__c.End_Date__c, System.today() + 1)
            .setField(SBQQ__QuoteLine__c.CurrencyIsoCode, 'USD')
            .setField(SBQQ__QuoteLine__c.Campaign_Name__c, CAMPAIGN_THANKSGIVING)
            .setField(
                SBQQ__QuoteLine__c.SBQQ__ProductName__c,
                CATEGORIES_SPONSORED_PRODUCTS_PACKAGE
            )
            .setField(SBQQ__QuoteLine__c.SBQQ__RequiredBy__c, marketplacePromotionQuoteLineItem)
            .setField(SBQQ__QuoteLine__c.Bid__c, 7)
            .setParent('SBQQ__RequiredBy__r', parentQuoteLineInstane);

        Fake childCollectionsQuoteLineInstance = new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, colectionsQuoteLineItem)
            .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, contractSignedQuote)
            .setField(SBQQ__QuoteLine__c.Start_Date__c, System.today() - 4)
            .setField(SBQQ__QuoteLine__c.End_Date__c, System.today() + 1)
            .setField(SBQQ__QuoteLine__c.CurrencyIsoCode, 'USD')
            .setField(SBQQ__QuoteLine__c.Campaign_Name__c, CAMPAIGN_THANKSGIVING)
            .setField(
                SBQQ__QuoteLine__c.SBQQ__ProductName__c,
                COLLECTIONS_SPONSORED_PRODUCTS_PACKAGE
            )
            .setField(SBQQ__QuoteLine__c.SBQQ__RequiredBy__c, marketplacePromotionQuoteLineItem)
            .setField(SBQQ__QuoteLine__c.Bid__c, 8)
            .setParent('SBQQ__RequiredBy__r', parentQuoteLineInstane);

        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>{
            (SBQQ__QuoteLine__c) ServiceMockDataBuilder.convertToSObject(parentQuoteLineInstane),
            (SBQQ__QuoteLine__c) ServiceMockDataBuilder.convertToSObject(
                childSearchQuoteLineInstance
            ),
            (SBQQ__QuoteLine__c) ServiceMockDataBuilder.convertToSObject(
                childDoubleDashQuoteLineInstance
            ),
            (SBQQ__QuoteLine__c) ServiceMockDataBuilder.convertToSObject(
                childCategoriesQuoteLineInstance
            ),
            (SBQQ__QuoteLine__c) ServiceMockDataBuilder.convertToSObject(
                childCollectionsQuoteLineInstance
            )
        };
        List<Quote_Brief_Relationship__c> quoteBriefRelationships = new List<Quote_Brief_Relationship__c>{
            (Quote_Brief_Relationship__c) new Fake(Quote_Brief_Relationship__c.class)
                .setField(
                    Quote_Brief_Relationship__c.Id,
                    marketplacePromotionQuoteBriefRelationship
                )
                .setField(Quote_Brief_Relationship__c.Quote__c, contractSignedQuote)
                .setField(Quote_Brief_Relationship__c.Brief__c, marketplacePromotionBrief)
                .setField(
                    Quote_Brief_Relationship__c.Campaign_of_Brief__c,
                    CAMPAIGN_HALLOWEEN_DEALS
                )
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        BriefItemsService.generateBriefItemsByQuoteLineItems(
            quoteLineItems,
            quoteBriefRelationships
        );
        /*Brief_Item__c marketplaceBriefItem = new Brief_Item__c(
            Brief__c = marketplacePromotionBrief,
            CurrencyIsoCode = null,
            Status__c = 'Waiting for Inputs',
            Number_of_Campaign_Setup_Errors_Found__c = 0,
            Opportunity_Owner__c = null,
            Holdout_Audience_Experiment__c = 'No',
            Evergreen_Ongoing_Promo__c = 'No',
            Store_Page_Banner_Included_for_Promo__c = 'No',
            Signed_Contract__c = null,
            Netsuite_ID__c = null,
            Categories_Bid__c = 7.0,
            Collections_Bid__c = 8.0,
            DoubleDash_Bid__c = 6.0,
            Search_Bid__c = 5.0,
            Affinity_Target_Audience__c = null,
            Applicable_DoorDash_Order_Types__c = null,
            Auto_Bidding__c = null,
            Average_Daily_Budget__c = null,
            Banner_Dates__c = NOT_APPLICABLE,
            Banner_Types__c = BANNER_TYPE_HOMEPAGE,
            Bid__c = null,
            Brands__c = null,
            Brief_Routing__c = null,
            Budget__c = null,
            Budget_Period__c = null,
            Campaign_Name__c = CAMPAIGN_HALLOWEEN_DEALS,
            Custom_Creative_Required__c = null,
            Daily_Budget_Cap__c = null,
            Max_Number_of_Redemptions_per_Cx__c = null,
            Max_Number_of_Redemptions_per_Cart__c = null,
            Minimum_required_spend_against_brand__c = null,
            Items_to_receive_discount__c = null,
            Day_Time_of_Week__c = null,
            Discount_Percentage_for_Consumer__c = null,
            Discounted_Delivery_Fee__c = null,
            End_Date__c = System.today(),
            Flat_Discount_for_Consumer__c = null,
            Incremental_Marketing_Fee_Redemption__c = 0.0,
            Sponsored_Listing_Terms__c = null,
            Max_Discount_for_Consumer__c = null,
            Max_Redemption_Cap__c = null,
            Menu_Item_Minimum_Quantity__c = null,
            Minimum_Banner_Fee__c = null,
            Minimum_Cart_Subtotal__c = null,
            Offer_Detailed_Description__c = null,
            Package__c = null,
            Payment_Protocol__c = 'Invoicing',
            Percent_of_Fee_to_Invoice_Merchant__c = null,
            Pricing_Type__c = 'Flat Fee',
            Product__c = 'Sponsored Products',
            Quote_Line__c = marketplacePromotionQuoteLineItem,
            Setup_Fee_Currency__c = null,
            Start_Date__c = System.today() - 1,
            Targeting__c = null,
            Term_Specific_Bidding__c = null,
            UPCs__c = null,
            Unit_Price__c = null,
            CRM_Campaign_Type__c = 'Email',
            Item_Description_Details__c = null,
            Item_Name__c = null,
            Item_Type__c = null,
            Influencer_Campaign_Platforms__c = null,
            Allow_Rewards_to_Expire_after_60_Days__c = null,
            Program_Type__c = null,
            Required_Spend_Threshold__c = null,
            Required_Visits_Threshold__c = null,
            Minimum_Spend_Per_Order__c = null,
            Reward_Type__c = null,
            Reward__c = null,
            Free_Item_Name_s__c = null,
            Co_funding_Cap_for_DPEI__c = null,
            Offsite_Platform__c = null,
			Offsite_Banner_Type__c = null,
			Offsite_Cx_Targeting_Type__c = null,
			Service_Fee_As_Percent_Budget__c  = null,
			Data_Fee_As_Percent_Budget__c = null
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerNew(marketplaceBriefItem);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }*/
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuoteLineItemsAndBriefsArePassedThenExceptionIsThrownForBriefItemsCreation() {
        Id marketplacePromotionQuoteLineItem = fflib_IDGenerator.generate(
            SBQQ__QuoteLine__c.SObjectType
        );
        Id advertisementQuoteLineItem = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id contractSignedQuote = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id marketplacePromotionBrief = fflib_IDGenerator.generate(Brief__c.SObjectType);
        Id advertisementBrief = fflib_IDGenerator.generate(Brief__c.SObjectType);
        Id marketplacePromotionQuoteBriefRelationship = fflib_IDGenerator.generate(
            Quote_Brief_Relationship__c.SObjectType
        );
        Id advertisementQuoteBriefRelationship = fflib_IDGenerator.generate(
            Quote_Brief_Relationship__c.SObjectType
        );

        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>{
            (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
                .setField(SBQQ__QuoteLine__c.Id, marketplacePromotionQuoteLineItem)
                .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, contractSignedQuote)
                .setField(SBQQ__QuoteLine__c.Campaign_Name__c, CAMPAIGN_HALLOWEEN_DEALS)
                .toSObject(),
            (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
                .setField(SBQQ__QuoteLine__c.Id, advertisementQuoteLineItem)
                .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, contractSignedQuote)
                .setField(SBQQ__QuoteLine__c.Campaign_Name__c, CAMPAIGN_THANKSGIVING)
                .toSObject()
        };
        List<Quote_Brief_Relationship__c> quoteBriefRelationships = new List<Quote_Brief_Relationship__c>{
            (Quote_Brief_Relationship__c) new Fake(Quote_Brief_Relationship__c.class)
                .setField(
                    Quote_Brief_Relationship__c.Id,
                    marketplacePromotionQuoteBriefRelationship
                )
                .setField(Quote_Brief_Relationship__c.Quote__c, contractSignedQuote)
                .setField(Quote_Brief_Relationship__c.Brief__c, marketplacePromotionBrief)
                .setField(
                    Quote_Brief_Relationship__c.Campaign_of_Brief__c,
                    CAMPAIGN_HALLOWEEN_DEALS
                )
                .toSObject(),
            (Quote_Brief_Relationship__c) new Fake(Quote_Brief_Relationship__c.class)
                .setField(Quote_Brief_Relationship__c.Id, advertisementQuoteBriefRelationship)
                .setField(Quote_Brief_Relationship__c.Quote__c, contractSignedQuote)
                .setField(Quote_Brief_Relationship__c.Brief__c, advertisementBrief)
                .setField(Quote_Brief_Relationship__c.Campaign_of_Brief__c, CAMPAIGN_THANKSGIVING)
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        ((fflib_ISObjectUnitOfWork) mocks.doThrowWhen(
                new TestCommitException('Exception occurred while performing DML operation'),
                mockUOW
            ))
            .commitWork();
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        try {
            BriefItemsService.generateBriefItemsByQuoteLineItems(
                quoteLineItems,
                quoteBriefRelationships
            );
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        } catch (Exception mockException) {
            System.assertEquals(
                'Exception occurred while performing DML operation',
                mockException.getMessage(),
                'Unexpected Error: The Exception fired was not a TestCommitException.'
            );
        }
    }

    /**
     * @description It is used to test if Brief Items for Sponsored Product package is updated
     * with auto-populated values from Sponsored Product Quote Line Items when new QLI is added
     */
    @isTest
    private static void testWhenSponsoredProductsQuoteLineItemsAndBriefsPassedThenBriefItemsUpdatedWithBidValues() {
        Id marketplacePromotionQuoteLineItem = fflib_IDGenerator.generate(
            SBQQ__QuoteLine__c.SObjectType
        );
        Id searchQuoteLineitem = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id doubleDashQuoteLineItem = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id contractSignedQuote = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id marketplacePromotionBrief = fflib_IDGenerator.generate(Brief__c.SObjectType);
        Id marketplacePromotionQuoteBriefRelationship = fflib_IDGenerator.generate(
            Quote_Brief_Relationship__c.SObjectType
        );
        Id briefItemId = fflib_IDGenerator.generate(Brief_Item__c.SObjectType);
        Fake parentQuoteLineInstane = new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, marketplacePromotionQuoteLineItem)
            .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, contractSignedQuote)
            .setField(SBQQ__QuoteLine__c.Campaign_Name__c, CAMPAIGN_HALLOWEEN_DEALS)
            .setField(SBQQ__QuoteLine__c.Start_Date__c, System.today() - 1)
            .setField(SBQQ__QuoteLine__c.End_Date__c, System.today())
            .setField(SBQQ__QuoteLine__c.Marketing_Flat_Fee__c, 0)
            .setField(SBQQ__QuoteLine__c.Payment_Method__c, PAYMENT_PROTOCOL_INVOICING)
            .setField(SBQQ__QuoteLine__c.Pricing_Type__c, PRICING_TYPE_FLAT_FEE)
            .setField(SBQQ__QuoteLine__c.Banner_Dates__c, NOT_APPLICABLE)
            .setField(SBQQ__QuoteLine__c.Banner_Type__c, BANNER_TYPE_HOMEPAGE)
            .setField(SBQQ__QuoteLine__c.User_Communication_Type__c, CRM_CAMPAIGN_TYPE_EMAIL)
            .setField(SBQQ__QuoteLine__c.SBQQ__ProductName__c, SPONSORED_PRODUCTS)
            .setField(SBQQ__QuoteLine__c.Has_Brief_Item__c, true);

        Fake childQuoteLineInstance = new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, searchQuoteLineitem)
            .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, contractSignedQuote)
            .setField(SBQQ__QuoteLine__c.Start_Date__c, System.today() - 4)
            .setField(SBQQ__QuoteLine__c.End_Date__c, System.today() + 1)
            .setField(SBQQ__QuoteLine__c.CurrencyIsoCode, 'USD')
            .setField(SBQQ__QuoteLine__c.Campaign_Name__c, CAMPAIGN_THANKSGIVING)
            .setField(SBQQ__QuoteLine__c.SBQQ__ProductName__c, SEARCH_SPONSORED_PRODUCTS_PACKAGE)
            .setField(SBQQ__QuoteLine__c.SBQQ__RequiredBy__c, marketplacePromotionQuoteLineItem)
            .setField(SBQQ__QuoteLine__c.Bid__c, 5)
            .setParent('SBQQ__RequiredBy__r', parentQuoteLineInstane);

        Fake briefItemInstance = new Fake(Brief_Item__c.class)
            .setField(Brief_Item__c.Id, briefItemId)
            .setField(Brief_Item__c.Brief__c, marketplacePromotionBrief)
            .setField(Brief_Item__c.Start_Date__c, System.today() - 4)
            .setField(Brief_Item__c.End_Date__c, System.today() + 1)
            .setField(Brief_Item__c.CurrencyIsoCode, 'USD')
            .setField(Brief_Item__c.Status__c, STATUS_WAITINGFORINPUTS)
            .setField(Brief_Item__c.Search_Bid__c, 5)
            .setField(Brief_Item__c.Quote_Line__c, marketplacePromotionQuoteLineItem)
            .setParent('Quote_Line__r', parentQuoteLineInstane);

        List<Quote_Brief_Relationship__c> quoteBriefRelationships = new List<Quote_Brief_Relationship__c>{
            (Quote_Brief_Relationship__c) new Fake(Quote_Brief_Relationship__c.class)
                .setField(
                    Quote_Brief_Relationship__c.Id,
                    marketplacePromotionQuoteBriefRelationship
                )
                .setField(Quote_Brief_Relationship__c.Quote__c, contractSignedQuote)
                .setField(Quote_Brief_Relationship__c.Brief__c, marketplacePromotionBrief)
                .setField(
                    Quote_Brief_Relationship__c.Campaign_of_Brief__c,
                    CAMPAIGN_HALLOWEEN_DEALS
                )
                .toSObject()
        };

        Fake childDoubleDashQuoteLineInstance = new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, doubleDashQuoteLineItem)
            .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, contractSignedQuote)
            .setField(SBQQ__QuoteLine__c.Start_Date__c, System.today() - 4)
            .setField(SBQQ__QuoteLine__c.End_Date__c, System.today() + 1)
            .setField(SBQQ__QuoteLine__c.CurrencyIsoCode, 'USD')
            .setField(SBQQ__QuoteLine__c.Campaign_Name__c, CAMPAIGN_THANKSGIVING)
            .setField(
                SBQQ__QuoteLine__c.SBQQ__ProductName__c,
                DOUBLEDASH_SPONSORED_PRODUCTS_PACKAGE
            )
            .setField(SBQQ__QuoteLine__c.SBQQ__RequiredBy__c, marketplacePromotionQuoteLineItem)
            .setField(SBQQ__QuoteLine__c.Bid__c, 6)
            .setParent('SBQQ__RequiredBy__r', parentQuoteLineInstane);

        List<SBQQ__QuoteLine__c> quoteLineItemsUpdate = new List<SBQQ__QuoteLine__c>{
            (SBQQ__QuoteLine__c) ServiceMockDataBuilder.convertToSObject(parentQuoteLineInstane),
            (SBQQ__QuoteLine__c) ServiceMockDataBuilder.convertToSObject(childQuoteLineInstance),
            (SBQQ__QuoteLine__c) ServiceMockDataBuilder.convertToSObject(
                childDoubleDashQuoteLineInstance
            )
        };

        List<Brief_Item__c> briefItemToUpdate = new List<Brief_Item__c>{
            (Brief_Item__c) ServiceMockDataBuilder.convertToSObject(briefItemInstance)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        BriefItemsSelector briefItemsSelectorMock = (BriefItemsSelector) mocks.mock(
            BriefItemsSelector.class
        );

        mocks.startStubbing();
        mocks.when(briefItemsSelectorMock.sObjectType()).thenReturn(Brief_Item__c.SObjectType);
        mocks.when(
                briefItemsSelectorMock.selectByQuoteLineItems(
                    new Set<Id>{ marketplacePromotionQuoteLineItem }
                )
            )
            .thenReturn(briefItemToUpdate);
        mocks.stopStubbing();
        Application.Selector.setMock(briefItemsSelectorMock);
        BriefItemsService.generateBriefItemsByQuoteLineItems(
            quoteLineItemsUpdate,
            quoteBriefRelationships
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Brief_Item__c.Id => briefItemId,
                        Brief_Item__c.DoubleDash_Bid__c => 6.0,
                        Brief_Item__c.Search_Bid__c => 5.0
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    } /**
     * @description It is used to test if Brief Items for Sponsored Product package is not updated
     * with bid values from Sponsored Product Quote Line Items when only sponsored Product QLI is added
     */
    @isTest
    private static void testWhenSponsoredProductsQuoteLineItemsArePassedThenBriefItemsCreatedWithNoUpdatedBidValues() {
        Id marketplacePromotionQuoteLineItem = fflib_IDGenerator.generate(
            SBQQ__QuoteLine__c.SObjectType
        );
        Id contractSignedQuote = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id marketplacePromotionBrief = fflib_IDGenerator.generate(Brief__c.SObjectType);
        Id marketplacePromotionQuoteBriefRelationship = fflib_IDGenerator.generate(
            Quote_Brief_Relationship__c.SObjectType
        );
        Fake parentQuoteLineInstane = new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, marketplacePromotionQuoteLineItem)
            .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, contractSignedQuote)
            .setField(SBQQ__QuoteLine__c.Campaign_Name__c, CAMPAIGN_HALLOWEEN_DEALS)
            .setField(SBQQ__QuoteLine__c.Start_Date__c, System.today() - 1)
            .setField(SBQQ__QuoteLine__c.End_Date__c, System.today())
            .setField(SBQQ__QuoteLine__c.Marketing_Flat_Fee__c, 0)
            .setField(SBQQ__QuoteLine__c.Payment_Method__c, PAYMENT_PROTOCOL_INVOICING)
            .setField(SBQQ__QuoteLine__c.Pricing_Type__c, PRICING_TYPE_FLAT_FEE)
            .setField(SBQQ__QuoteLine__c.Banner_Dates__c, NOT_APPLICABLE)
            .setField(SBQQ__QuoteLine__c.Banner_Type__c, BANNER_TYPE_HOMEPAGE)
            .setField(SBQQ__QuoteLine__c.User_Communication_Type__c, CRM_CAMPAIGN_TYPE_EMAIL)
            .setField(SBQQ__QuoteLine__c.SBQQ__ProductName__c, SPONSORED_PRODUCTS)
            .setField(SBQQ__QuoteLine__c.Has_Brief_Item__c, false);

        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>{
            (SBQQ__QuoteLine__c) ServiceMockDataBuilder.convertToSObject(parentQuoteLineInstane)
        };
        List<Quote_Brief_Relationship__c> quoteBriefRelationships = new List<Quote_Brief_Relationship__c>{
            (Quote_Brief_Relationship__c) new Fake(Quote_Brief_Relationship__c.class)
                .setField(
                    Quote_Brief_Relationship__c.Id,
                    marketplacePromotionQuoteBriefRelationship
                )
                .setField(Quote_Brief_Relationship__c.Quote__c, contractSignedQuote)
                .setField(Quote_Brief_Relationship__c.Brief__c, marketplacePromotionBrief)
                .setField(
                    Quote_Brief_Relationship__c.Campaign_of_Brief__c,
                    CAMPAIGN_HALLOWEEN_DEALS
                )
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        BriefItemsService.generateBriefItemsByQuoteLineItems(
            quoteLineItems,
            quoteBriefRelationships
        );
        /*Brief_Item__c marketplaceBriefItem = new Brief_Item__c(
            Brief__c = marketplacePromotionBrief,
            CurrencyIsoCode = null,
            Status__c = 'Waiting for Inputs',
            Number_of_Campaign_Setup_Errors_Found__c = 0,
            Opportunity_Owner__c = null,
            Holdout_Audience_Experiment__c = 'No',
            Evergreen_Ongoing_Promo__c = 'Yes',
            Store_Page_Banner_Included_for_Promo__c = 'No',
            Signed_Contract__c = null,
            Netsuite_ID__c = null,
            Affinity_Target_Audience__c = null,
            Applicable_DoorDash_Order_Types__c = null,
            Auto_Bidding__c = null,
            Average_Daily_Budget__c = null,
            Banner_Dates__c = null,
            Banner_Types__c = null,
            Bid__c = null,
            Brands__c = null,
            Brief_Routing__c = null,
            Budget__c = null,
            Budget_Period__c = null,
            Campaign_Name__c = CAMPAIGN_HALLOWEEN_DEALS,
            Custom_Creative_Required__c = null,
            Daily_Budget_Cap__c = null,
            Max_Number_of_Redemptions_per_Cx__c = null,
            Max_Number_of_Redemptions_per_Cart__c = null,
            Minimum_required_spend_against_brand__c = null,
            Items_to_receive_discount__c = null,
            //Categories_Bid__c = null,
            //Collections_Bid__c = null,
            Day_Time_of_Week__c = null,
            Discount_Percentage_for_Consumer__c = null,
            Discounted_Delivery_Fee__c = null,
            End_Date__c = System.today(),
            Flat_Discount_for_Consumer__c = null,
            Incremental_Marketing_Fee_Redemption__c = 0.0,
            Incremental_Marketing_Fee_Redemption__c = null,
            Is_this_a_Complex_Deal_Picklist__c = null,
            Sponsored_Listing_Terms__c = null,
            Max_Discount_for_Consumer__c = null,
            Max_Redemption_Cap__c = null,
            Menu_Item_Minimum_Quantity__c = null,
            Minimum_Banner_Fee__c = null,
            Minimum_Cart_Subtotal__c = null,
            Offer_Detailed_Description__c = null,
            Package__c = null,
            Payment_Protocol__c = null,
            Percent_of_Fee_to_Invoice_Merchant__c = null,
            Pricing_Type__c = null,
            Product__c = 'CRM',
            Quote_Line__c = marketplacePromotionQuoteLineItem,
            //Search_Bid__c = null,
            Setup_Fee_Currency__c = null,
            Start_Date__c = null,
            Targeting__c = null,
            Term_Specific_Bidding__c = null,
            UPCs__c = null,
            Unit_Price__c = null,
            CRM_Campaign_Type__c = 'Email',
            Item_Description_Details__c = null,
            Item_Name__c = null,
            Item_Type__c = null,
            Influencer_Campaign_Platforms__c = null,
            Allow_Rewards_to_Expire_after_60_Days__c = null,
            Program_Type__c = null,
            Required_Spend_Threshold__c = null,
            Required_Visits_Threshold__c = null,
            Minimum_Spend_Per_Order__c = null,
            Reward_Type__c = null,
            Reward__c = null,
            Free_Item_Name_s__c = null,
            Co_funding_Cap_for_DPEI__c = null,
            Offsite_Platform__c = null,
			Offsite_Banner_Type__c = null,
			Offsite_Cx_Targeting_Type__c = null,
			Service_Fee_As_Percent_Budget__c = null,
			Data_Fee_As_Percent_Budget__c  = null
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerNew(marketplaceBriefItem);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }*/
    }

    /**
     * @description It is used to test if Brief Items for CnG Product package is not created
     *  CnG Product Quote Line Item is available
     */
    @isTest
    private static void testWhenCnGProductsQuoteLineItemsArePassedThenBriefItemsCreatedWithNoUpdatedBidValues() {
        Id searchQuoteLineItem = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id contractSignedQuote = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id marketplacePromotionBrief = fflib_IDGenerator.generate(Brief__c.SObjectType);
        Id marketplacePromotionQuoteBriefRelationship = fflib_IDGenerator.generate(
            Quote_Brief_Relationship__c.SObjectType
        );

        Fake childSearchQuoteLineInstance = new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, searchQuoteLineItem)
            .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, contractSignedQuote)
            .setField(SBQQ__QuoteLine__c.Start_Date__c, System.today() - 4)
            .setField(SBQQ__QuoteLine__c.End_Date__c, System.today() + 1)
            .setField(SBQQ__QuoteLine__c.CurrencyIsoCode, 'USD')
            .setField(SBQQ__QuoteLine__c.Campaign_Name__c, CAMPAIGN_THANKSGIVING)
            .setField(SBQQ__QuoteLine__c.SBQQ__ProductName__c, SEARCH_SPONSORED_PRODUCTS_PACKAGE)
            .setField(SBQQ__QuoteLine__c.SBQQ__RequiredBy__c, null)
            .setField(SBQQ__QuoteLine__c.Bid__c, 5);

        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>{
            (SBQQ__QuoteLine__c) ServiceMockDataBuilder.convertToSObject(
                childSearchQuoteLineInstance
            )
        };
        List<Quote_Brief_Relationship__c> quoteBriefRelationships = new List<Quote_Brief_Relationship__c>{
            (Quote_Brief_Relationship__c) new Fake(Quote_Brief_Relationship__c.class)
                .setField(
                    Quote_Brief_Relationship__c.Id,
                    marketplacePromotionQuoteBriefRelationship
                )
                .setField(Quote_Brief_Relationship__c.Quote__c, contractSignedQuote)
                .setField(Quote_Brief_Relationship__c.Brief__c, marketplacePromotionBrief)
                .setField(
                    Quote_Brief_Relationship__c.Campaign_of_Brief__c,
                    CAMPAIGN_HALLOWEEN_DEALS
                )
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        BriefItemsService.generateBriefItemsByQuoteLineItems(
            quoteLineItems,
            quoteBriefRelationships
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description testing updating opps by brief
     */

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenBriefsAreUpdatedThenOpportunitiesAreUpdated() {
        Id oppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id briefId = fflib_IDGenerator.generate(Brief__c.SObjectType);
        Set<Schema.SObjectField> oppFieldSet = new Set<Schema.SObjectField>{
            Opportunity.SObjectType.getDescribe().fields.getMap().get('Name'),
            Opportunity.SObjectType.getDescribe().fields.getMap().get('Campaign_TLDR__c'),
            Opportunity.SObjectType.getDescribe().fields.getMap().get('Purchase_Order__c')
        };

        List<Opportunity> testOpps = new List<Opportunity>{
            new Opportunity(
                Id = oppId,
                Name = 'TestOpp',
                Campaign_TLDR__c = null,
                Purchase_Order__c = null
            )
        };
        List<Brief__c> briefList = new List<Brief__c>{
            new Brief__c(
                Id = briefId,
                Opportunity_Name__c = oppId,
                Campaign_TLDR__c = 'testTLDR',
                Purchase_Order__c = '123'
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        OpportunitiesSelector selectorMock = (OpportunitiesSelector) mocks.mock(
            OpportunitiesSelector.class
        );
        OpportunityToBriefMappingSelector mappingSelectorMock = (OpportunityToBriefMappingSelector) mocks.mock(
            OpportunityToBriefMappingSelector.class
        );
        //Mocking
        mocks.startStubbing();
        mocks.when(mappingSelectorMock.getOpportunityFieldSet()).thenReturn(oppFieldSet);
        mocks.when(selectorMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(selectorMock.getOpportunitiesToSyncFromBriefs(new Set<Id>{ oppId }))
            .thenReturn(testOpps);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        BriefsService.updateOpportunityFromBrief(briefList);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
    /**
     * @description tests that when campaign status is changed, emails are sent
     */
    @isTest
    private static void testWhenCampaignStatusChangesThenValidateEmailsSentForCompleted() {
        Id briefItemId = Fake.generateId(Brief_Item__c.class);
        Set<Id> briefIds = new Set<Id>();
        briefIds.add(briefItemId);
        Id userId = Fake.generateId(User.class);
        Contact newContact = new Contact(
            Email = 'testEMail@testEmail.com',
            Firstname = 'Testy',
            LastName = 'Testerson'
        );
        insert newContact;
        User usr = new User(Id = userId, Email = 'testEMail@testEmail.com');

        List<Brief_Item__c> briefItemList = new List<Brief_Item__c>{
            new Brief_Item__c(
                Id = briefItemId,
                In_Campaign_Change__c = 'Yes-Completed',
                OwnerId = usr.Id,
                Opportunity_Owner__r = usr,
                Opportunity_Owner__c = usr.Id
            )
        };
        List<Brief_Item__c> oldBriefItemList = new List<Brief_Item__c>{
            new Brief_Item__c(
                Id = briefItemId,
                In_Campaign_Change__c = 'Yes',
                OwnerId = usr.Id,
                Opportunity_Owner__r = usr,
                Opportunity_Owner__c = usr.Id
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        IBriefItems briefItemsMocks = (IBriefItems) mocks.mock(IBriefItems.class);
        IBriefItemsSelector briefItemSelectorMock = (IBriefItemsSelector) mocks.mock(
            IBriefItemsSelector.class
        );
        mocks.startStubbing();
        mocks.when(briefItemsMocks.getType()).thenReturn(Schema.Brief_Item__c.SObjectType);
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(briefItemsMocks);
        mocks.when(briefItemSelectorMock.sObjectType()).thenReturn(Brief_Item__c.SObjectType);
        mocks.when(briefItemSelectorMock.selectByIds(briefIds)).thenReturn(briefItemList);
        mocks.stopStubbing();
        Application.Domain.setMock(briefItemsMocks);
        Application.SELECTOR.setMock(briefItemSelectorMock);
        BriefItems.setConstructorMock(constructor);
        BriefItemsService.sendCampaignCompletedEmails(
            new Map<Id, SObject>(oldBriefItemList),
            briefItemList
        );
        System.assertEquals(1, Limits.getEmailInvocations(), 'Email not sent for campaign change');
    }
    /**
     * @description tests if campaign change field is updated when associated fields are updated
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMetaDataFieldsAreUpdatedThenCampaignChangeIsUpdated() {
        Id briefItemId = Fake.generateId(Brief_Item__c.class);
        Set<Id> briefIds = new Set<Id>();
        briefIds.add(briefItemId);
        Id userId = Fake.generateId(User.class);
        Contact newContact = new Contact(
            Email = 'testEMail@testEmail.com',
            Firstname = 'Testy',
            LastName = 'Testerson'
        );
        insert newContact;
        User usr = new User(Id = userId, Email = 'testEMail@testEmail.com');

        List<Brief_Item__c> briefItemList = new List<Brief_Item__c>{
            new Brief_Item__c(
                Id = briefItemId,
                Status__c = 'Testing - New Submission',
                In_Campaign_Change__c = 'Yes',
                budget__c = 123,
                OwnerId = usr.Id,
                Opportunity_Owner__r = usr,
                Opportunity_Owner__c = usr.Id
            )
        };
        List<Brief_Item__c> oldBriefItemList = new List<Brief_Item__c>{
            new Brief_Item__c(
                Id = briefItemId,
                In_Campaign_Change__c = '',
                OwnerId = usr.Id,
                Opportunity_Owner__r = usr,
                Opportunity_Owner__c = usr.Id
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        IBriefItems briefItemsMocks = (IBriefItems) mocks.mock(IBriefItems.class);
        IBriefItemsSelector briefItemSelectorMock = (IBriefItemsSelector) mocks.mock(
            IBriefItemsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(briefItemsMocks.getType()).thenReturn(Schema.Brief_Item__c.SObjectType);
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(briefItemsMocks);
        mocks.when(briefItemSelectorMock.sObjectType()).thenReturn(Brief_Item__c.SObjectType);
        mocks.when(briefItemSelectorMock.selectByIds(briefIds)).thenReturn(briefItemList);
        mocks.stopStubbing();
        Application.Domain.setMock(briefItemsMocks);
        Application.SELECTOR.setMock(briefItemSelectorMock);
        BriefItems.setConstructorMock(constructor);
        Application.UNITOFWORK.setMock(mockUOW);
        fflib_SObjectDomain.Test.Database.onUpdate(
            briefItemList,
            new Map<Id, SObject>(oldBriefItemList)
        );
        fflib_SObjectDomain.triggerHandler(BriefItemsHandler.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        System.assertEquals(2, Limits.getEmailInvocations(), 'Email not sent for campaign change');
    }

    /**
     * @description This method is to test that updating quotelines from briefitems
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenBriefItemsAreGivenThenQuotelineUpdated() {
        Id advertisementQuoteLineItem = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id contractSignedQuote = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id marketplacePromotionBrief = fflib_IDGenerator.generate(Brief__c.SObjectType);
        Id briefItemId = fflib_IDGenerator.generate(Brief_Item__c.SObjectType);

        Fake parentQuoteLineInstane = new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, advertisementQuoteLineItem)
            .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, contractSignedQuote)
            .setField(SBQQ__QuoteLine__c.CurrencyIsoCode, 'USD')
            .setField(SBQQ__QuoteLine__c.Campaign_Name__c, CAMPAIGN_THANKSGIVING)
            .setField(SBQQ__Quoteline__c.Brief_Item__c, briefItemId)
            .setField(SBQQ__Quoteline__c.Has_Brief_Item__c, true)
            .setField(SBQQ__QuoteLine__c.SBQQ__ProductName__c, 'CRM');

        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>{
            (SBQQ__QuoteLine__c) ServiceMockDataBuilder.convertToSObject(parentQuoteLineInstane)
        };

        List<Brief_Item__c> briefItemToUpdate = new List<Brief_Item__c>{
            (Brief_Item__c) new Fake(Brief_Item__c.class)
                .setField(Brief_Item__c.Id, briefItemId)
                .setField(Brief_Item__c.Brief__c, marketplacePromotionBrief)
                .setField(Brief_Item__c.Quote_Line__c, advertisementQuoteLineItem)
                .setField(Brief_Item__c.Start_Date__c, System.today() - 3)
                .setField(Brief_Item__c.End_Date__c, System.today() + 5)
                .setParent('Quote_Line__r', parentQuoteLineInstane)
                .toSObject()
        };
        Map<Id, SBQQ__Quoteline__c> mapIdToQuoteline = new Map<Id, SBQQ__Quoteline__c>();
        mapIdToQuoteline.put(advertisementQuoteLineItem, quoteLineItems[0]);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        IBriefItemsSelector briefItemsSelectorMock = (IBriefItemsSelector) mocks.mock(
            IBriefItemsSelector.class
        );
        IQuoteLineItemsSelector selectorMock = (IQuoteLineItemsSelector) mocks.mock(
            IQuoteLineItemsSelector.class
        );
        //mocking
        mocks.startStubbing();
        mocks.when(briefItemsSelectorMock.sObjectType()).thenReturn(Brief_Item__c.SObjectType);
        mocks.when(briefItemsSelectorMock.selectByIds(new Set<Id>{ briefItemId }))
            .thenReturn(briefItemToUpdate);
        mocks.when(selectorMock.sObjectType()).thenReturn(SBQQ__QuoteLine__c.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ advertisementQuoteLineItem }))
            .thenReturn(quoteLineItems);
        mocks.when(
                selectorMock.selectQuoteLinesFromIdsWithBriefItems(
                    new Set<Id>{ advertisementQuoteLineItem }
                )
            )
            .thenReturn(mapIdToQuoteline);
        mocks.stopStubbing();
        Application.Selector.setMock(briefItemsSelectorMock);
        Application.Selector.setMock(selectorMock);

        BriefItemsService.updateQuoteLinesFromBriefItems(briefItemToUpdate);
        //verify
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    @isTest
    private static void testWhenBriefItemTrackingObjectShouldBeCreatedThenReturnTrue() {
        Brief_Item__c existingBriefItemWaiting = new Brief_Item__c(
            Status__c = STATUS_WAITINGFORINPUTS,
            Campaign_Link_s__c = null,
            Budget__c = 2500
        );
        Brief_Item__c updatedBriefItemCampaignBuilding = new Brief_Item__c(
            Status__c = STATUS_CAMPAIGN_BUILDING,
            Campaign_Link_s__c = null,
            Budget__c = 2500
        );
        //Test LEM-11961
        Boolean returnedValueShouldBeFalse = BriefItemsServiceImpl.shouldBriefItemTrackingObjectBeCreated(
            existingBriefItemWaiting,
            updatedBriefItemCampaignBuilding
        );
        System.assertEquals(false, returnedValueShouldBeFalse, 'Call should return false');

        Brief_Item__c updatedBriefItemCampaignLinkSet = new Brief_Item__c(
            Status__c = STATUS_CAMPAIGN_BUILDING,
            Campaign_Link_s__c = 'Non Null text',
            Budget__c = 2500
        );
        Boolean returnedValueShouldBeTrue = BriefItemsServiceImpl.shouldBriefItemTrackingObjectBeCreated(
            existingBriefItemWaiting,
            updatedBriefItemCampaignLinkSet
        );
        System.assertEquals(true, returnedValueShouldBeTrue, 'Call should return true');

        Brief_Item__c updatedBriefItemBiggerBudget = new Brief_Item__c(
            Status__c = STATUS_CAMPAIGN_BUILDING,
            Campaign_Link_s__c = null,
            Budget__c = 3000
        );
        returnedValueShouldBeTrue = BriefItemsServiceImpl.shouldBriefItemTrackingObjectBeCreated(
            updatedBriefItemCampaignBuilding,
            updatedBriefItemBiggerBudget
        );
        System.assertEquals(true, returnedValueShouldBeTrue, 'Call should return true');
    }
    /**
     * @description This method is to test that when given a map of brief item id to quote line
     * the brief item values will be updated
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenMapGivenThenBriefItemsAreUpdated() {
        Id advertisementQuoteLineItem = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id contractSignedQuote = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id marketplacePromotionBrief = fflib_IDGenerator.generate(Brief__c.SObjectType);
        Id briefItemId = fflib_IDGenerator.generate(Brief_Item__c.SObjectType);

        Fake parentQuoteLineInstane = new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, advertisementQuoteLineItem)
            .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, contractSignedQuote)
            .setField(SBQQ__QuoteLine__c.CurrencyIsoCode, 'USD')
            .setField(SBQQ__QuoteLine__c.Campaign_Name__c, CAMPAIGN_THANKSGIVING)
            .setField(SBQQ__Quoteline__c.Brief_Item__c, briefItemId)
            .setField(SBQQ__Quoteline__c.Has_Brief_Item__c, true)
            .setField(SBQQ__QuoteLine__c.SBQQ__ProductName__c, 'CRM');

        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>{
            (SBQQ__QuoteLine__c) ServiceMockDataBuilder.convertToSObject(parentQuoteLineInstane)
        };

        List<Brief_Item__c> briefItemToUpdate = new List<Brief_Item__c>{
            (Brief_Item__c) new Fake(Brief_Item__c.class)
                .setField(Brief_Item__c.Id, briefItemId)
                .setField(Brief_Item__c.Brief__c, marketplacePromotionBrief)
                .setField(Brief_Item__c.Quote_Line__c, advertisementQuoteLineItem)
                .setField(Brief_Item__c.Start_Date__c, System.today() - 3)
                .setField(Brief_Item__c.End_Date__c, System.today() + 5)
                .setParent('Quote_Line__r', parentQuoteLineInstane)
                .toSObject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        IBriefItemsSelector briefItemsSelectorMock = (IBriefItemsSelector) mocks.mock(
            IBriefItemsSelector.class
        );
        IQuoteLineItemsSelector selectorMock = (IQuoteLineItemsSelector) mocks.mock(
            IQuoteLineItemsSelector.class
        );
        mocks.startStubbing();
        mocks.when(briefItemsSelectorMock.sObjectType()).thenReturn(Brief_Item__c.SObjectType);
        mocks.when(briefItemsSelectorMock.selectByIds(new Set<Id>{ briefItemId }))
            .thenReturn(briefItemToUpdate);
        mocks.when(selectorMock.sObjectType()).thenReturn(SBQQ__QuoteLine__c.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ advertisementQuoteLineItem }))
            .thenReturn(quoteLineItems);
        mocks.stopStubbing();
        Application.Selector.setMock(briefItemsSelectorMock);
        Application.Selector.setMock(selectorMock);
        SBQQ__Quoteline__c line = quoteLineItems[0];

        Map<Id, SBQQ__Quoteline__c> briefItemIdToQuotelineMap = new Map<Id, SBQQ__QuoteLine__c>();
        briefItemIdToQuotelineMap.put(briefItemId, line);
        BriefItemsService.updateAgencyFieldOnExistingBriefItems(briefItemIdToQuotelineMap);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description This method is to test that when given a map of Quote id to Content Document Id
     * with opportunity Agency Value Null the brief item values will be updated
     */
    @isTest
    public static void testWhenMapOfQuoteIdAndContentDocumentIdGivenThenBriefItemsAreUpdated() {
        Id quoteLineItem1 = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id quoteLineItem2 = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id quote1 = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id quote2 = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id brief1 = fflib_IDGenerator.generate(Brief__c.SObjectType);
        Id brief2 = fflib_IDGenerator.generate(Brief__c.SObjectType);
        Id briefItemId1 = fflib_IDGenerator.generate(Brief_Item__c.SObjectType);
        Id briefItemId2 = fflib_IDGenerator.generate(Brief_Item__c.SObjectType);
        Id contentDocumentId = fflib_IDGenerator.generate(ContentDocument.SObjectType);
        Id opportunityId1 = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id opportunityId2 = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);

        Fake parentQuoteLineInstane1 = new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, quoteLineItem1)
            .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, quote1)
            .setField(SBQQ__QuoteLine__c.CurrencyIsoCode, 'USD')
            .setField(SBQQ__QuoteLine__c.Campaign_Name__c, CAMPAIGN_THANKSGIVING)
            .setField(SBQQ__Quoteline__c.Brief_Item__c, briefItemId1)
            .setField(SBQQ__Quoteline__c.Has_Brief_Item__c, true)
            .setField(SBQQ__QuoteLine__c.SBQQ__ProductName__c, 'CRM');

        Fake parentQuoteLineInstane2 = new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, quoteLineItem2)
            .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, quote2)
            .setField(SBQQ__QuoteLine__c.CurrencyIsoCode, 'USD')
            .setField(SBQQ__QuoteLine__c.Campaign_Name__c, CAMPAIGN_THANKSGIVING)
            .setField(SBQQ__Quoteline__c.Brief_Item__c, briefItemId2)
            .setField(SBQQ__Quoteline__c.Has_Brief_Item__c, true)
            .setField(SBQQ__QuoteLine__c.SBQQ__ProductName__c, 'CRM');

        Fake opportunityInstance1 = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId1)
            .setField(Opportunity.Agency__c, null);

        Fake opportunityInstance2 = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId2)
            .setField(Opportunity.Agency__c, accountId);

        Fake briefInstance1 = new Fake(Brief__c.class)
            .setField(Brief__c.ID, brief1)
            .setField(Brief__c.Opportunity_Name__c, opportunityId1)
            .setParent('Opportunity_Name__r', opportunityInstance1);

        Fake briefInstance2 = new Fake(Brief__c.class)
            .setField(Brief__c.ID, brief2)
            .setField(Brief__c.Opportunity_Name__c, opportunityId2)
            .setParent('Opportunity_Name__r', opportunityInstance2);

        Fake briefItemInstance1 = new Fake(Brief_Item__c.class)
            .setField(Brief_Item__c.Id, briefItemId1)
            .setField(Brief_Item__c.Brief__c, brief1)
            .setField(Brief_Item__c.Quote_Line__c, quoteLineItem1)
            .setField(Brief_Item__c.Start_Date__c, System.today() - 3)
            .setField(Brief_Item__c.End_Date__c, System.today() + 5)
            .setField(Brief_Item__c.Draft_Contract__c, '')
            .setField(Brief_Item__c.Draft_Agency_Contract__c, '')
            .setParent('Brief__r', briefInstance1)
            .setParent('Quote_Line__r', parentQuoteLineInstane1);

        Fake briefItemInstance2 = new Fake(Brief_Item__c.class)
            .setField(Brief_Item__c.Id, briefItemId2)
            .setField(Brief_Item__c.Brief__c, brief2)
            .setField(Brief_Item__c.Quote_Line__c, quoteLineItem2)
            .setField(Brief_Item__c.Start_Date__c, System.today() - 3)
            .setField(Brief_Item__c.End_Date__c, System.today() + 5)
            .setField(Brief_Item__c.Draft_Contract__c, '')
            .setField(Brief_Item__c.Draft_Agency_Contract__c, '')
            .setParent('Brief__r', briefInstance2)
            .setParent('Quote_Line__r', parentQuoteLineInstane2);

        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>{
            (SBQQ__QuoteLine__c) ServiceMockDataBuilder.convertToSObject(parentQuoteLineInstane1),
            (SBQQ__QuoteLine__c) ServiceMockDataBuilder.convertToSObject(parentQuoteLineInstane2)
        };
        List<Brief_Item__c> briefItemToUpdate = new List<Brief_Item__c>{
            (Brief_Item__c) ServiceMockDataBuilder.convertToSObject(briefItemInstance1),
            (Brief_Item__c) ServiceMockDataBuilder.convertToSObject(briefItemInstance2)
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        IBriefItemsSelector briefItemsSelectorMock = (IBriefItemsSelector) mocks.mock(
            IBriefItemsSelector.class
        );
        IQuoteLineItemsSelector selectorMock = (IQuoteLineItemsSelector) mocks.mock(
            IQuoteLineItemsSelector.class
        );
        mocks.startStubbing();
        mocks.when(briefItemsSelectorMock.sObjectType()).thenReturn(Brief_Item__c.SObjectType);
        mocks.when(
                briefItemsSelectorMock.selectBriefItemsWithQuoteIds(new Set<Id>{ quote1, quote2 })
            )
            .thenReturn(briefItemToUpdate);
        mocks.when(selectorMock.sObjectType()).thenReturn(SBQQ__QuoteLine__c.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ quoteLineItem1 }))
            .thenReturn(quoteLineItems);
        mocks.stopStubbing();
        Application.Selector.setMock(briefItemsSelectorMock);
        Application.Selector.setMock(selectorMock);

        Map<Id, Id> quoteToContentDocMap = new Map<Id, Id>();
        quoteToContentDocMap.put(quote1, contentDocumentId);
        quoteToContentDocMap.put(quote2, contentDocumentId);
        BriefItemsService.updateDraftIoTemplateOnExistingBriefItems(quoteToContentDocMap);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        System.assertNotEquals(
            '',
            briefItemToUpdate[0].Draft_Contract__c,
            'Draft Contract is Null'
        );
        System.assertEquals(
            '',
            briefItemToUpdate[0].Draft_Agency_Contract__c,
            'Draft Agency Contract is Not Null'
        );
        System.assertEquals('', briefItemToUpdate[1].Draft_Contract__c, 'Draft Contract is Null');
        System.assertNotEquals(
            '',
            briefItemToUpdate[1].Draft_Agency_Contract__c,
            'Draft Agency Contract is Not Null'
        );
    }
}