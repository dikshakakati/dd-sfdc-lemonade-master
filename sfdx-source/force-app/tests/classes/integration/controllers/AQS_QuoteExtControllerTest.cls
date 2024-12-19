/**
 * @author ATG
 * @date 2022-04-20
 * @description This is test class for AQS_QuoteExtController class
 */
@isTest
private class AQS_QuoteExtControllerTest {
    private static final String ACCOUNT_NAME = 'Hello World';
    private static final String INVALID_ASSERT_MESSAGE = 'Unexpected result';
    private static final String INVALID_ASSERT_MESSAGE_FOR_APPROVAL = 'Unexpected result: Quote status is not Approved';
    private static final String PRODUCT_DELIVERY = 'Delivery';
    private static final String PRODUCT_LOF = 'Large Order Fulfillment (LOF)';
    private static final String COMMISSION_FEE_TYPE = 'Commission';
    private static final String SMB_SEGMENT = 'SMB';
    private static final String DISTANCE_BASED = 'Distance Based (incl. tiered)';
    private static final String SPONSORED_LISTINGS = 'Sponsored Listings';
    private static final String CUSTOM_MARKETING_PROMOTION = 'Custom Marketing Promotion';
    private static final String MARKETPLACE_PROMOTION = 'Marketplace Promotion';
    private static final String ADVERTISEMENT = 'Advertisement';
    /**
     * @description To test Submit for approval.
     */
    @isTest
    static void testWhenSubmitThenQuoteApproved() {
        SBQQ__Quote__c quote = createQuote(true);
        Test.startTest();
        AQS_QuoteExtController con = new AQS_QuoteExtController(
            new ApexPages.StandardController(quote)
        );
        con.onSubmit();
        quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        Test.stopTest();

        System.assertEquals(
            'Approved',
            quote.ApprovalStatus__c,
            'Approval Status should be Approved'
        );
    }

    @isTest
    static void testWhenSubmitThenVerifyQuoteApprovals() {
        // Rx from Australia or New Zealand
        SBQQ__Quote__c quote = createQuote(true);
        Account testAccount = [
            SELECT Id, Primary_Vertical__c, BillingCountry, BillingCountryCode
            FROM Account
            WHERE Id = :quote.SBQQ__Account__c
            LIMIT 1
        ];
        testAccount.BillingCountryCode = 'AU';
        testAccount.BillingCountry = 'Australia';
        testAccount.Primary_Vertical__c = 'Rx';
        update testAccount;

        AQS_QuoteExtController con = new AQS_QuoteExtController(
            new ApexPages.StandardController(quote)
        );
        con.onSubmit();

        quote = [SELECT Id, Jira_Request_Ticket_status__c FROM SBQQ__Quote__c WHERE Id = :quote.Id];
        System.assertEquals(
            quote.Jira_Request_Ticket_status__c,
            'Waiting for Support',
            'The Jira Ticket Status should be updated'
        );

        // Non-Rx
        Test.startTest();
        SBQQ__Quote__c testQuoteNonRx = createQuote(true);

        AQS_QuoteExtController con2 = new AQS_QuoteExtController(
            new ApexPages.StandardController(testQuoteNonRx)
        );
        con2.onSubmit();

        testQuoteNonRx = [
            SELECT Id, Jira_Request_Ticket_status__c
            FROM SBQQ__Quote__c
            WHERE Id = :testQuoteNonRx.Id
        ];
        Test.stopTest();

        System.assertEquals(
            testQuoteNonRx.Jira_Request_Ticket_status__c,
            'Waiting for Support',
            'The Jira Ticket Status should be updated'
        );
    }

    /**
     * @description To test an Error on Submit
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    static void testWhenErrorSubmitThenCancel() {
        SBQQ__Quote__c quote = createQuote(true);
        Test.startTest();
        AQS_QuoteExtController con = new AQS_QuoteExtController(
            new ApexPages.StandardController(quote)
        );

        // Delete the quote in order to throw an error
        delete quote;

        con.onSubmit();
        Test.stopTest();

        con.onCancel();
    }

    /**
     * @description To test Recall
     */
    @isTest
    static void testWhenRecallThenQuoteRecalled() {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Approval_Requested_Reason__c = 'Test';
        insert quote;

        Test.startTest();
        AQS_QuoteExtController con = new AQS_QuoteExtController(
            new ApexPages.StandardController(quote)
        );
        con.onRecall();
        quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        Test.stopTest();

        System.assertEquals(
            'Recalled',
            quote.ApprovalStatus__c,
            'Approval Status should be Recalled'
        );
    }

    /**
     * @description To test an Error on Recall
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    static void testWhenErrorRecallThenCancel() {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Approval_Requested_Reason__c = 'Test';
        insert quote;

        Test.startTest();
        AQS_QuoteExtController con = new AQS_QuoteExtController(
            new ApexPages.StandardController(quote)
        );

        // Delete the quote in order to throw an error
        delete quote;

        con.onRecall();
        Test.stopTest();

        con.onCancel();
    }

    @IsTest
    static void testWhenStandardDMFProductIsPresentThenReturnTrue() {
        SBQQ__Quote__c quote = createQuote(true);
        createQuoteLineForStandardDMF(quote);

        Test.startTest();
        Boolean hasDMFQuoteLine = AQS_QuoteExtController.hasStandardDMF(quote.Id);
        Boolean shouldBeFalse = AQS_QuoteExtController.hasStandardDMF(null);

        delete [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quote.Id];
        Boolean shouldBeFalse2 = AQS_QuoteExtController.hasStandardDMF(quote.Id);
        Test.stopTest();

        System.assert(hasDMFQuoteLine, 'There should be a Standard DMF Product here');
        System.assert(!shouldBeFalse, 'There should be no DMF Product in this null scenario');
        System.assert(!shouldBeFalse2, 'There should be no DMF Product in this scenario');
    }

    /**
     * @description To create test quote
     * @param doInsert
     * @return SBQQ__Quote__c
     */
    private static SBQQ__Quote__c createQuote(Boolean doInsert) {
        Account testAccount = new Account(
            Segment__c = 'Enterprise',
            Primary_Vertical__c = null,
            Name = 'Test Account'
        );
        insert testAccount;

        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            SBQQ__Account__c = testAccount.Id,
            Contract_Generation_Path__c = 'Non-Templatized'
        );
        if (doInsert) {
            insert testQuote;
        }
        return testQuote;
    }

    /**
     * @description Creates a QLI for "Standard DMF" which is need in the controller
     * @param testQuote
     * @return SBQQ__QuoteLine__c
     */
    private static SBQQ__QuoteLine__c createQuoteLineForStandardDMF(SBQQ__Quote__c testQuote) {
        SBQQ.TriggerControl.disable();

        Product2 product = CPQTestDataFactory.createProduct(false);
        product.Family = 'Advertisement';
        product.ProductCode = AQS_QuoteExtController.PRODUCT_CODE_STANDARD_DMF;
        insert product;

        SBQQ__QuoteLine__c quoteLine = CPQTestDataFactory.createQuoteLine(
            product,
            testQuote,
            false
        );

        quoteLine.SBQQ__Quote__c = testQuote.Id;
        insert quoteLine;
        return quoteLine;
    }

    @IsTest
    static void testWhenQuoteNeedsJiraLinkThenValidate() {
        /*
        VALID URL FORMATS:
        https://doordash.atlassian.net/servicedesk/customer/portal/70/EASD-7490?created=true
        https://doordash.atlassian.net/browse/EASD-13066
        */

        Set<String> validUrls = new Set<String>{
            'https://doordash.atlassian.net/servicedesk/customer/portal/70/EASD-7490?created=true',
            'https://doordash.atlassian.net/servicedesk/customer/portal/70/EASD-7490',
            'https://doordash.atlassian.net/servicedesk/customer/portal/70/EASD-123456789',
            'https://doordash.atlassian.net/servicedesk/customer/portal/70/EASD-1',
            'https://doordash.atlassian.net/servicedesk/customer/portal/70/EASD-7490?',
            'https://doordash.atlassian.net/servicedesk/customer/portal/70/EASD-7490?moreParams=true&moreParams2=false&moreParams3=false',
            'https://doordash.atlassian.net/browse/EASD-13066',
            'https://doordash.atlassian.net/browse/EASD-13066?q=testParams',
            'https://doordash.atlassian.net/browse/EASD-0000000001'
        };

        // This method throws an exception for invalid URLs, so if we call with valid URLs then
        // nothing should happen
        for (String thisUrl : validUrls) {
            AQS_QuoteExtController.checkJiraLinkFormat(thisUrl);
        }

        Set<String> invalidUrls = new Set<String>{
            'https://doordash.atlassian.net/servicedesk/customer/portal/70/BASD-7490?created=true',
            'https://doordash.atlassian.net/servicedesk/customer/portal/70/EASD-',
            'https://doordash.atlassian.net/servicedesk/customer/portal/70/EASD',
            '.net/servicedesk/customer/portal/70/EASD-7490',
            'https://doordash.atlassian.net/servicedesk/customer/portal/70/LEM-1234',
            'https://doordash.atlassian.net/servicedesk/customer/portal/LEM-1234',
            'doordash.atlassian.net/servicedesk/customer/portal/LEM-1234',
            'https://atlassian.net/servicedesk/customer/portal/LEM-1234',
            'https://doordash.atlassian.net/browse/EASD-',
            'https://atlassian.net/browse/EASD-1234'
        };

        for (String thisUrl : invalidUrls) {
            Boolean hasError = false;
            try {
                AQS_QuoteExtController.checkJiraLinkFormat(thisUrl);
            } catch (AQS_QuoteExtController.SubmitException se) {
                hasError = se.getMessage()
                    .containsIgnoreCase(AQS_QuoteExtController.ERROR_MSG_INVALID_JIRA_LINK);
            }

            System.assert(
                hasError,
                'The null scenario should have thrown a missing Jira Link error'
            );
        }

        // Test null/blank scenario
        Boolean hasError = false;

        try {
            AQS_QuoteExtController.checkJiraLinkFormat(null);
        } catch (AQS_QuoteExtController.SubmitException se) {
            hasError = se.getMessage()
                .containsIgnoreCase(AQS_QuoteExtController.ERROR_MSG_MISSING_JIRA_LINK);
        }

        System.assert(hasError, 'The null scenario should have thrown a missing Jira Link error');

        // Skip validation logic for users with certain permissions, like Admins
        Id adminProfileId;
        List<Profile> profiles = ProfilesSelector.newInstance()
            .selectByNames(new Set<String>{ 'System Administrator' });
        if (!profiles.isEmpty()) {
            adminProfileId = profiles[0].Id;
        }

        User adminUser = new User(
            Alias = 'admin',
            Email = 'adminUserTesting@doordash.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = adminProfileId,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'adminUserTesting@doordash.com.test'
        );

        System.runAs(adminUser) {
            AQS_QuoteExtController.validateJiraLink('https://doordash.atlassian.net/browse/EASD-');
        }
    }

    /**
     * @description It is used to test whether or not an error message is thrown when a quote has 0
     * 'Number of stores' with 'Advertisement' Quote lines.
     */
    @isTest
    static void testWhenQuoteNoOfStoresInvalidWithAdsMPPRQuoteLineThenErrorThrown() {
        Account account = new Account();
        account.Segment__C = SMB_SEGMENT;
        account.Name = ACCOUNT_NAME;
        insert account;
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Approval_Requested_Reason__c = 'Test';
        quote.Number_of_Stores__c = 0;
        quote.Check_Delay_After_Activation_For_A_P__c = false;
        quote.Check_Start_Date_For_A_P_Product__c = false;
        quote.Use_Corporate_Cherry_Picking__c = false;
        quote.SBQQ__Account__c = account.Id;
        insert quote;

        Test.startTest();
        AQS_QuoteExtController controller = new AQS_QuoteExtController(
            new ApexPages.StandardController(quote)
        );
        controller.onSubmit();
        Test.stopTest();
        System.assertEquals(ApexPages.getMessages().size(), 1, INVALID_ASSERT_MESSAGE);
    }

    /**
     * @description It is used to test whether or not an error message is thrown when
     * 'Approval Requested Reason' is blank on Quote.
     */
    @isTest
    static void testWhenApprovalRequestedReasonBlankOnQuoteThenErrorThrown() {
        Account account = new Account();
        account.Segment__c = SMB_SEGMENT;
        account.Name = ACCOUNT_NAME;
        insert account;
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Approval_Requested_Reason__c = null;
        quote.Number_of_Stores__c = 0;
        quote.Check_Delay_After_Activation_For_A_P__c = false;
        quote.Check_Start_Date_For_A_P_Product__c = false;
        quote.Use_Corporate_Cherry_Picking__c = false;
        quote.SBQQ__Account__c = account.Id;
        insert quote;
        Test.startTest();
        AQS_QuoteExtController controller = new AQS_QuoteExtController(
            new ApexPages.StandardController(quote)
        );
        controller.onSubmit();
        Test.stopTest();
        System.assertEquals(ApexPages.getMessages().size(), 1, INVALID_ASSERT_MESSAGE);
    }

    /**
     * @description It is used to test whether or not an error message is thrown when
     * 'Check Delay After Activation For A&P' is true for A&P Quote.
     */
    @isTest
    static void testWhenDelayAfterActivationForAdsAndPromosQuoteIsYesThenErrorThrown() {
        Account account = new Account();
        account.Segment__C = SMB_SEGMENT;
        account.Name = ACCOUNT_NAME;
        insert account;
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Number_of_Stores__c = 10;
        quote.Check_Delay_After_Activation_For_A_P__c = true;
        quote.Check_Start_Date_For_A_P_Product__c = true;
        quote.Use_Corporate_Cherry_Picking__c = false;
        quote.SBQQ__Account__c = account.Id;
        insert quote;

        Test.startTest();
        AQS_QuoteExtController controller = new AQS_QuoteExtController(
            new ApexPages.StandardController(quote)
        );
        controller.onSubmit();
        Test.stopTest();
        System.assertEquals(ApexPages.getMessages().size(), 2, INVALID_ASSERT_MESSAGE);
    }

    /**
     * @description It is used to test if Min/Max delivery fee is blank for Alcohol Delivery/Delivery
     * Quote Lines under LOF Package with  Fee Type as 'Commission' or 'Fee'.
     */
    @isTest
    static void testWhenMinMaxDeliveryFeeBlankForLOFThenErrorThrown() {
        Account account = new Account();
        account.Segment__C = SMB_SEGMENT;
        account.Name = ACCOUNT_NAME;
        insert account;
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Account__c = account.Id;
        quote.Number_of_Stores__c = 10;
        insert quote;
        Product2 productDelivery = CPQTestDataFactory.createProduct(false);
        productDelivery.Name = PRODUCT_DELIVERY;
        insert productDelivery;
        Product2 productLOF = CPQTestDataFactory.createProduct(false);
        productLOF.Name = PRODUCT_LOF;
        insert productLOF;
        SBQQ__ProductOption__c productOption = new SBQQ__ProductOption__c();
        productOption.SBQQ__OptionalSKU__c = productDelivery.Id;
        productOption.SBQQ__ConfiguredSKU__c = productLOF.Id;
        productOption.SBQQ__Number__c = 1;
        insert productOption;
        SBQQ__QuoteLine__c quoteLine = CPQTestDataFactory.createQuoteLine(
            productDelivery,
            quote,
            false
        );
        quoteline.SBQQ__ProductOption__c = productOption.Id;
        quoteLine.Fee_Type__c = COMMISSION_FEE_TYPE;
        quoteLine.Min__c = null;
        quoteLine.Max__c = null;
        quoteLine.Segment__c = SMB_SEGMENT;
        insert quoteLine;
        Test.startTest();
        AQS_QuoteExtController controller = new AQS_QuoteExtController(
            new ApexPages.StandardController(quote)
        );
        controller.onSubmit();
        Test.stopTest();
        System.assertEquals(1, ApexPages.getMessages().size(), INVALID_ASSERT_MESSAGE);
    }
    /**
     * @description It is used to test if Delivery option under SOF/LOF has delivery type as Distance Based
     *  and Contracting_Flow__c is not 'Redlining' then throw error on submit for approval.
     */
    @isTest
    private static void testWhenDriveDeliveryProductDeliveryTypeDistanceBasedAndContractingFlowNotRedliningThenErrorThrown() {
        Account account = new Account();
        account.Segment__C = SMB_SEGMENT;
        account.Name = ACCOUNT_NAME;
        insert account;
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Account__c = account.Id;
        quote.Number_of_Stores__c = 10;
        insert quote;
        Product2 productDelivery = CPQTestDataFactory.createProduct(false);
        productDelivery.Name = PRODUCT_DELIVERY;
        insert productDelivery;
        Product2 productLOF = CPQTestDataFactory.createProduct(false);
        productLOF.Name = PRODUCT_LOF;
        insert productLOF;
        SBQQ__ProductOption__c productOption = new SBQQ__ProductOption__c();
        productOption.SBQQ__OptionalSKU__c = productDelivery.Id;
        productOption.SBQQ__ConfiguredSKU__c = productLOF.Id;
        productOption.SBQQ__Number__c = 1;
        insert productOption;
        SBQQ__QuoteLine__c quoteLine = CPQTestDataFactory.createQuoteLine(
            productDelivery,
            quote,
            false
        );
        quoteline.SBQQ__ProductOption__c = productOption.Id;
        quoteLine.Delivery_Type__c = DISTANCE_BASED;
        quoteLine.SBQQ__Existing__c = false;
        quoteLine.Segment__c = SMB_SEGMENT;
        insert quoteLine;
        Test.startTest();
        AQS_QuoteExtController controller = new AQS_QuoteExtController(
            new ApexPages.StandardController(quote)
        );
        controller.onSubmit();
        Test.stopTest();
        System.assertEquals(1, ApexPages.getMessages().size(), INVALID_ASSERT_MESSAGE);
    }
    /**
     * @description It is used to test if  throw error on submit for approval.
     */
    @isTest
    private static void testWhenApplicableAdsAndPromosFieldsValuedTogetherThenErrorThrown() {
        Account account = new Account();
        account.Segment__C = SMB_SEGMENT;
        account.Name = ACCOUNT_NAME;
        insert account;
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Account__c = account.Id;
        insert quote;
        Product2 sponsoredListings = CPQTestDataFactory.createProduct(false);
        sponsoredListings.Name = SPONSORED_LISTINGS;
        sponsoredListings.Family = MARKETPLACE_PROMOTION;
        insert sponsoredListings;
        Product2 customMarketingPromotion = CPQTestDataFactory.createProduct(false);
        customMarketingPromotion.Name = CUSTOM_MARKETING_PROMOTION;
        customMarketingPromotion.Family = ADVERTISEMENT;
        insert customMarketingPromotion;

        SBQQ__QuoteLine__c quoteLineSponsoredListings = CPQTestDataFactory.createQuoteLine(
            sponsoredListings,
            quote,
            false
        );
        quoteLineSponsoredListings.SBQQ__Existing__c = false;
        quoteLineSponsoredListings.Bid__c = 5;
        quoteLineSponsoredListings.Auto_Bidding__c = true;
        quoteLineSponsoredListings.Segment__c = SMB_SEGMENT;
        insert quoteLineSponsoredListings;
        SBQQ__QuoteLine__c quoteLineCustomMarketing = CPQTestDataFactory.createQuoteLine(
            customMarketingPromotion,
            quote,
            false
        );
        quoteLineCustomMarketing.SBQQ__Existing__c = false;
        quoteLineCustomMarketing.Discount_Percentage_for_Consumer__c = 5;
        //quoteLineCustomMarketing.Flat_Discount_Amount_for_Consumer__c = 5;
        quoteLineCustomMarketing.Max_Amount_from_Marketing_Percent__c = 5;
        quoteLineCustomMarketing.Marketing_Only_Commission__c = 5;
        quoteLineCustomMarketing.Max_Discount_Amount_for_Consumer__c = 5;
        quoteLineCustomMarketing.Segment__c = SMB_SEGMENT;
        insert quoteLineCustomMarketing;
        Test.startTest();
        AQS_QuoteExtController controller = new AQS_QuoteExtController(
            new ApexPages.StandardController(quote)
        );
        controller.onSubmit();
        Test.stopTest();
        System.assertEquals(2, ApexPages.getMessages().size(), INVALID_ASSERT_MESSAGE);
    }
    /**
     * @description It is used to test if  throw error on submit for approval.
     */
    @isTest
    private static void testWhenApplicableAdsAndPromosFieldsNotValuedTogetherThenErrorThrown() {
        Account account = new Account();
        account.Segment__C = SMB_SEGMENT;
        account.Name = ACCOUNT_NAME;
        insert account;
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Account__c = account.Id;
        insert quote;
        Product2 sponsoredListings = CPQTestDataFactory.createProduct(false);
        sponsoredListings.Name = SPONSORED_LISTINGS;
        sponsoredListings.Family = MARKETPLACE_PROMOTION;
        insert sponsoredListings;
        Product2 customMarketingPromotion = CPQTestDataFactory.createProduct(false);
        customMarketingPromotion.Name = CUSTOM_MARKETING_PROMOTION;
        customMarketingPromotion.Family = ADVERTISEMENT;
        insert customMarketingPromotion;

        SBQQ__QuoteLine__c quoteLineSponsoredListings = CPQTestDataFactory.createQuoteLine(
            sponsoredListings,
            quote,
            false
        );
        quoteLineSponsoredListings.SBQQ__Existing__c = false;
        quoteLineSponsoredListings.Bid__c = null;
        quoteLineSponsoredListings.Auto_Bidding__c = false;
        quoteLineSponsoredListings.Segment__c = SMB_SEGMENT;
        insert quoteLineSponsoredListings;
        SBQQ__QuoteLine__c quoteLineCustomMarketing = CPQTestDataFactory.createQuoteLine(
            customMarketingPromotion,
            quote,
            false
        );
        quoteLineCustomMarketing.SBQQ__Existing__c = false;
        quoteLineCustomMarketing.Discount_Percentage_for_Consumer__c = null;
        quoteLineCustomMarketing.Flat_Discount_Amount_for_Consumer__c = null;
        quoteLineCustomMarketing.Segment__c = SMB_SEGMENT;
        insert quoteLineCustomMarketing;
        Test.startTest();
        AQS_QuoteExtController controller = new AQS_QuoteExtController(
            new ApexPages.StandardController(quote)
        );
        controller.onSubmit();
        Test.stopTest();
        System.assertEquals(3, ApexPages.getMessages().size(), INVALID_ASSERT_MESSAGE);
    }
}