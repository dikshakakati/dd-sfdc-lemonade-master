/**
 * @author Deloitte
 * @date 11/30/2022
 * @description Test class for Brief Items selector.
 */
@isTest(SeeAllData=false)
private class BriefItemsSelectorTest {
    /**
     * @description This method used to test BriefItemsSelector class
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        BriefItemsSelector selector = new BriefItemsSelector();
        List<Schema.SObjectField> fieldList = selector.getSObjectFieldList();
        Schema.SObjectType typeOfObj = selector.getSObjectType();
        System.assertEquals(8, fieldList.size(), ' Mismatch in field list');
        System.assertEquals(
            Schema.Brief_Item__c.SObjectType,
            typeOfObj,
            'The object type must be Contacts'
        );
    }

    /**
     * @description It is used to test if the Brief Items are fetched.
     */
    @isTest
    private static void testWhenBriefIdsArePassedThenBriefItemsWaitingForInputsAreFetched() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account[] businessAccounts = new List<Account>{
            new Account(Name = 'Name1', RecordTypeId = accRecordTypeBusiness, Segment__c = 'Enterprise'),
            new Account(Name = 'Name2', RecordTypeId = accRecordTypeBusiness, Segment__c = 'Enterprise')
        };
        insert businessAccounts;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;

        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = businessAccounts[0].Id,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Pricebook2Id = pricebookId
            )
        };
        insert opportunityList;

        List<Brief__c> briefs = new List<Brief__c>{
            new Brief__c(
                Is_Created_By_System__c = true,
                CampaignName__c = 'Campaign Name',
                Additional_Notes__c = 'Additional Notes',
                Opportunity_Name__c = opportunityList[0].Id,
                Opportunity_Owner__c = UserInfo.getUserId(),
                Netsuite_ID__c = 'NetSuite ID',
                Configuration__c = 'Standard (Launch Ops)'
            )
        };
        insert briefs;

        Product2 product = CPQTestDataFactory.createProduct(true);
        product.Family = 'Advertisements';
        update product;
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(
            opportunityList[0],
            businessAccounts[0],
            null,
            true
        );
        SBQQ__QuoteLine__c quoteLine = CPQTestDataFactory.createQuoteLine(product, quote, true);
        quote.SBQQ__Status__c = 'Approved';
        quote.Signed_Contract_Link__c = 'Link';
        quote.Contract_Signed_Date__c = System.today() - 5;
        update quote;

        quoteLine.Campaign_Name__c = 'Halloween Deals';
        quoteLine.Marketing_Flat_Fee__c = 22;
        update quoteLine;

        List<Brief_Item__c> briefItems = new List<Brief_Item__c>{
            new Brief_Item__c(
                Is_Created_By_System__c = true,
                Brief__c = briefs[0].Id,
                Campaign_Name__c = 'Campaign Name',
                Start_Date__c = System.today() - 1,
                End_Date__c = System.today() + 5,
                Quote_Line__c = quoteLine.Id,
                Status__c = 'Waiting for Inputs',
                Payment_Protocol__c = 'Invoicing',
                Store_Page_Banner_Included_for_Promo__c = 'Yes',
                Incremental_Marketing_Fee_Redemption__c = 1
            )
        };
        insert briefItems;

        List<Brief_Item__c> newBriefItem = BriefItemsSelector.newInstance()
            .selectByBriefAndStatus(new Set<Id>{ briefs[0].Id });

        System.assertEquals(
            1,
            newBriefItem.size(),
            'The Brief Items were not appropriately fetched.'
        );
    }

    /**
     * @description It is used to test if the Brief Items are fetched.
     */
    @isTest
    private static void testWhenBriefIdsArePassedThenBriefItemsAreFetched() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account[] businessAccounts = new List<Account>{
            new Account(Name = 'Name1', RecordTypeId = accRecordTypeBusiness, Segment__c = 'Enterprise' ),
            new Account(Name = 'Name2', RecordTypeId = accRecordTypeBusiness, Segment__c = 'Enterprise')
        };
        insert businessAccounts;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;

        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = businessAccounts[0].Id,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Pricebook2Id = pricebookId
            )
        };
        insert opportunityList;

        List<Brief__c> briefs = new List<Brief__c>{
            new Brief__c(
                Is_Created_By_System__c = true,
                CampaignName__c = 'Campaign Name',
                Additional_Notes__c = 'Additional Notes',
                Opportunity_Name__c = opportunityList[0].Id,
                Opportunity_Owner__c = UserInfo.getUserId(),
                Netsuite_ID__c = 'NetSuite ID',
                Configuration__c = 'Standard (Launch Ops)'
            )
        };
        insert briefs;

        Product2 product = CPQTestDataFactory.createProduct(true);
        product.Family = 'Advertisements';
        update product;
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(
            opportunityList[0],
            businessAccounts[0],
            null,
            true
        );
        SBQQ__QuoteLine__c quoteLine = CPQTestDataFactory.createQuoteLine(product, quote, true);
        quote.SBQQ__Status__c = 'Approved';
        quote.Signed_Contract_Link__c = 'Link';
        quote.Contract_Signed_Date__c = System.today() - 5;
        update quote;

        quoteLine.Campaign_Name__c = 'Halloween Deals';
        quoteLine.Marketing_Flat_Fee__c = 22;
        update quoteLine;

        List<Brief_Item__c> briefItems = new List<Brief_Item__c>{
            new Brief_Item__c(
                Is_Created_By_System__c = true,
                Brief__c = briefs[0].Id,
                Campaign_Name__c = 'Campaign Name',
                Start_Date__c = System.today() - 1,
                End_Date__c = System.today() + 5,
                Quote_Line__c = quoteLine.Id,
                Status__c = 'Waiting for Inputs',
                Payment_Protocol__c = 'Invoicing',
                Store_Page_Banner_Included_for_Promo__c = 'Yes',
                Incremental_Marketing_Fee_Redemption__c = 1
            )
        };
        insert briefItems;

        List<Brief_Item__c> newBriefItem = BriefItemsSelector.newInstance()
            .selectByBrief(new Set<Id>{ briefs[0].Id });

        System.assertEquals(
            1,
            newBriefItem.size(),
            'The Brief Items were not appropriately fetched.'
        );
    }
    /**
     * @description It is used to test if the Brief Items are fetched
     * when we are filtering on QuotelineIds.
     */
    @isTest
    private static void testWhenQuoteLineIdsArePassedThenBriefItemsAreFetched() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account[] businessAccounts = new List<Account>{
            new Account(Name = 'Name1', RecordTypeId = accRecordTypeBusiness, Segment__c = 'Enterprise')
        };
        insert businessAccounts;

        Id pricebookId = Test.getStandardPricebookId();

        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = businessAccounts[0].Id,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Pricebook2Id = pricebookId
            )
        };
        insert opportunityList;

        List<Brief__c> briefs = new List<Brief__c>{
            new Brief__c(
                Is_Created_By_System__c = true,
                CampaignName__c = 'Campaign Name',
                Additional_Notes__c = 'Additional Notes',
                Opportunity_Name__c = opportunityList[0].Id,
                Opportunity_Owner__c = UserInfo.getUserId(),
                Netsuite_ID__c = 'NetSuite ID',
                Configuration__c = 'Standard (Launch Ops)'
            )
        };
        insert briefs;

        Product2 product = new Product2();
        product.Name = 'Try Me Free';
        product.Description = 'Product';
        product.IsActive = true;
        product.ProductCode = 'P-00342';
        product.SBQQ__AssetAmendmentBehavior__c = 'Default';
        product.SBQQ__AssetConversion__c = 'One per quote line';
        product.SBQQ__BillingFrequency__c = 'Monthly';
        product.SBQQ__BillingType__c = 'Advance';
        product.SBQQ__ChargeType__c = 'Recurring';
        product.SBQQ__ConfigurationEvent__c = 'Always';
        product.SBQQ__ConfigurationType__c = 'Allowed';
        product.SBQQ__DefaultQuantity__c = 1;
        product.SBQQ__PriceEditable__c = true;
        product.SBQQ__PricingMethod__c = 'List';
        product.SBQQ__SubscriptionBase__c = 'List';
        product.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        product.SBQQ__SubscriptionTerm__c = 1;
        product.SBQQ__SubscriptionType__c = 'Renewable';
        product.Family = 'Advertisement';
        insert product;

        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(
            opportunityList[0],
            businessAccounts[0],
            null,
            true
        );
        SBQQ__QuoteLine__c quoteLine = CPQTestDataFactory.createQuoteLine(product, quote, false);
        quoteLine.Has_Brief_Item__c = true;
        insert quoteLine;

        List<Brief_Item__c> briefItems = new List<Brief_Item__c>{
            new Brief_Item__c(
                Is_Created_By_System__c = true,
                Brief__c = briefs[0].Id,
                Start_Date__c = System.today() - 1,
                End_Date__c = System.today() + 5,
                Quote_Line__c = quoteLine.Id,
                Status__c = 'Waiting for Inputs',
                Payment_Protocol__c = 'Invoicing',
                Store_Page_Banner_Included_for_Promo__c = 'Yes',
                Incremental_Marketing_Fee_Redemption__c = 1
            )
        };
        insert briefItems;

        List<Brief_Item__c> newBriefItem = BriefItemsSelector.newInstance()
            .selectByQuoteLineItems(new Set<Id>{ quoteLine.Id });

        System.assertEquals(
            1,
            newBriefItem.size(),
            'The Brief Items were not appropriately fetched.'
        );
    }

    @isTest
    private static void testWhenUsingSelectByOppsThenOppsAreReturned() {
        Id briefId = Fake.generateId(Brief__c.class);
        Id quoteLineId = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id oppId = Fake.generateId(Opportunity.class);
        Set<Id> oppIds = new Set<Id>{ oppId };
        List<Brief_Item__c> briefItemsList = new List<Brief_Item__c>{
            new Brief_Item__c(
                Is_Created_By_System__c = true,
                Brief__c = briefId,
                Start_Date__c = System.today() - 1,
                End_Date__c = System.today() + 5,
                Quote_Line__c = quoteLineId,
                Status__c = 'Waiting for Inputs',
                Payment_Protocol__c = 'Invoicing',
                Store_Page_Banner_Included_for_Promo__c = 'Yes'
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        BriefItemsSelector briefItemsSelectorMock = (BriefItemsSelector) mocks.mock(
            BriefItemsSelector.class
        );
        //mocking
        mocks.startStubbing();
        mocks.when(briefItemsSelectorMock.getSObjectType()).thenReturn(Brief_Item__c.SObjectType);
        mocks.when(briefItemsSelectorMock.selectByOpportunities(oppIds)).thenReturn(briefItemsList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(briefItemsSelectorMock);
        List<Brief_Item__c> returnedBriefItems = BriefItemsSelector.newInstance()
            .selectByOpportunities(oppIds);
        System.assertNotEquals(
            briefItemsList.size(),
            returnedBriefItems.size(),
            'Returned Brief Items do not match'
        );
    }

    @isTest
    private static void testWhenUsingSelectByIdsThenBriefsItemsAreReturned() {
        Id briefId = Fake.generateId(Brief__c.class);
        Id quoteLineId = Fake.generateId(SBQQ__QuoteLine__c.class);
        Set<Id> briefIds = new Set<Id>{ briefId };
        List<Brief_Item__c> briefItemsList = new List<Brief_Item__c>{
            new Brief_Item__c(
                Is_Created_By_System__c = true,
                Brief__c = briefId,
                Start_Date__c = System.today() - 1,
                End_Date__c = System.today() + 5,
                Quote_Line__c = quoteLineId,
                Status__c = 'Waiting for Inputs',
                Payment_Protocol__c = 'Invoicing',
                Store_Page_Banner_Included_for_Promo__c = 'Yes'
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        BriefItemsSelector briefItemsSelectorMock = (BriefItemsSelector) mocks.mock(
            BriefItemsSelector.class
        );
        mocks.startStubbing();
        mocks.when(briefItemsSelectorMock.getSObjectType()).thenReturn(Brief_Item__c.SObjectType);
        mocks.when(briefItemsSelectorMock.selectByIds(briefIds)).thenReturn(briefItemsList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(briefItemsSelectorMock);
        List<Brief_Item__c> returnedBriefItems = BriefItemsSelector.newInstance()
            .selectByIds(briefIds);
        System.assertNotEquals(
            briefItemsList.size(),
            returnedBriefItems.size(),
            'Returned Brief Items do not match'
        );
    }

    @isTest
    private static void testWhenUsingSelectBriefItemsWithRoutingAndCustomCreativeThenBriefItemsAreReturned() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account[] businessAccounts = new List<Account>{
            new Account(Name = 'Name1', RecordTypeId = accRecordTypeBusiness, Segment__c = 'Enterprise'),
            new Account(Name = 'Name2', RecordTypeId = accRecordTypeBusiness, Segment__c = 'Enterprise')
        };
        insert businessAccounts;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;

        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = businessAccounts[0].Id,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Pricebook2Id = pricebookId
            )
        };
        insert opportunityList;

        List<Brief__c> briefs = new List<Brief__c>{
            new Brief__c(
                Is_Created_By_System__c = true,
                CampaignName__c = 'Campaign Name',
                Additional_Notes__c = 'Additional Notes',
                Opportunity_Name__c = opportunityList[0].Id,
                Opportunity_Owner__c = UserInfo.getUserId(),
                Netsuite_ID__c = 'NetSuite ID',
                Configuration__c = 'Standard (Launch Ops)'
            )
        };
        insert briefs;

        Product2 product = CPQTestDataFactory.createProduct(true);
        product.Family = 'Advertisements';
        update product;
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(
            opportunityList[0],
            businessAccounts[0],
            null,
            true
        );
        SBQQ__QuoteLine__c quoteLine = CPQTestDataFactory.createQuoteLine(product, quote, true);
        quote.SBQQ__Status__c = 'Approved';
        quote.Signed_Contract_Link__c = 'Link';
        quote.Contract_Signed_Date__c = System.today() - 5;
        update quote;

        quoteLine.Campaign_Name__c = 'Halloween Deals';
        quoteLine.Marketing_Flat_Fee__c = 22;
        update quoteLine;

        List<Brief_Item__c> briefItems = new List<Brief_Item__c>{
            new Brief_Item__c(
                Is_Created_By_System__c = true,
                Brief__c = briefs[0].Id,
                Campaign_Name__c = 'Campaign Name',
                Start_Date__c = System.today() - 1,
                End_Date__c = System.today() + 5,
                Quote_Line__c = quoteLine.Id,
                Status__c = 'Waiting for Inputs',
                Payment_Protocol__c = 'Invoicing',
                Store_Page_Banner_Included_for_Promo__c = 'Yes'
            )
        };
        insert briefItems;

        List<Brief_Item__c> newBriefItem = BriefItemsSelector.newInstance()
            .selectBriefItemsWithRoutingAndCustomCreative(new Set<Id>{ briefs[0].Id });

        System.assertEquals(
            1,
            newBriefItem.size(),
            'The Brief Items were not appropriately fetched.'
        );
    }

    @isTest
    private static void testWhenQuoteIdsArePassedThenBriefsItemsAreReturned() {

        Test.startTest();
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Business')
        .getRecordTypeId();
        Account[] businessAccounts = new List<Account>{
            new Account(Name = 'Name1', RecordTypeId = accRecordTypeBusiness, Segment__c = 'SMB')
        };
        insert businessAccounts;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;

        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Prospecting',
                CloseDate = System.today().addDays(5),
                AccountId = businessAccounts[0].Id,
                Deal_Type__c= 'Standard',
                Opportunity_Sub_Type__c= 'Former Partner',
                Pricebook2Id = pricebookId,
                Estimated_Number_Of_Stores__c = 1
            )
        };
        insert opportunityList;

        List<Brief__c> briefs = new List<Brief__c>{
            new Brief__c(
                Is_Created_By_System__c = true,
                CampaignName__c = 'Campaign Name',
                Additional_Notes__c = 'Additional Notes',
                Opportunity_Name__c = opportunityList[0].Id,
                Opportunity_Owner__c = UserInfo.getUserId()
            )
        };
        insert briefs;

        Product2 product = CPQTestDataFactory.createProduct(true);
        product.Family = 'Advertisements';
        update product;

        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(
            opportunityList[0],
            businessAccounts[0],
            null,
            false
        );
        quote.SBQQ__Status__c = 'Approved';
        insert quote;

        SBQQ__QuoteLine__c quoteLine = CPQTestDataFactory.createQuoteLine(product, quote, false);
        insert quoteLine;

        List<Brief_Item__c> briefItems = new List<Brief_Item__c>{
            new Brief_Item__c(
                Is_Created_By_System__c = true,
                Brief__c = briefs[0].Id,
                Campaign_Name__c = 'Campaign Name',
                Quote_Line__c = quoteLine.Id,
                Status__c = 'Waiting for Inputs',
                Payment_Protocol__c = 'Invoicing'
            )
        };
        insert briefItems;

        List<Brief_Item__c> newBriefItem = BriefItemsSelector.newInstance()
            .selectBriefItemsWithQuoteIds(new Set<Id>{ quote.Id });

        Test.stopTest();

        System.assertEquals(
            1,
            newBriefItem.size(),
            'The Brief Items were not appropriately fetched.'
        );

    }
}