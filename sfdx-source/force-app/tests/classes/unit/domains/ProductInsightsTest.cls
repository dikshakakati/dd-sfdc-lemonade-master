/**
 * @description Test Class for ProductInsights Domain class
 * @author Deloitte
 * @date 06/04/2022
 */
@isTest(seeAllData=false)
public with sharing class ProductInsightsTest {
    @isTest
    private static void testWhenInsightAreInsertedThenBlankAccountsArePopulatedFromOpportunity() {
        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 2')
        };

        List<Opportunity> opportunitiesRec = new List<Opportunity>{
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[0].Id
            ),
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[1].Id,
                Opportunity_Sub_Type__c = 'Net New Partner'
            )
        };

        Product_Insights__c[] insightsList = new List<Product_Insights__c>{
            new Product_Insights__c(
                Opportunity__c = opportunitiesRec[0].Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested'
            ),
            new Product_Insights__c(
                Opportunity__c = opportunitiesRec[1].Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunitiesSelector selectorMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );

        mocks.startStubbing();

        mocks.when(selectorMock.SObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(selectorMock.selectByInsights(insightsList)).thenReturn(opportunitiesRec);

        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);
        IProductInsights insightsInstance = ProductInsights.newInstance(insightsList);

        insightsInstance.autopopulateAccountOnInsights();
        System.assertNotEquals(
            null,
            insightsList[0].Account_Name__c,
            'The parent Account was not autopopulated at all'
        );
        System.assertNotEquals(
            null,
            insightsList[1].Account_Name__c,
            'The parent Account was not autopopulated at all'
        );
        System.assertEquals(
            accountList[0].Id,
            insightsList[0].Account_Name__c,
            'The parent Account was not autopopulated appropriately'
        );
        System.assertEquals(
            accountList[1].Id,
            insightsList[1].Account_Name__c,
            'The parent Account was not autopopulated appropriately'
        );
    }

    @isTest
    private static void testWhenInsightsAreInsertedThenBlankAccountFieldsArePopulatedFromInitiative() {
        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 2')
        };

        List<Initiative__c> initativeRec = new List<Initiative__c>{
            new Initiative__c(
                Id = fflib_IDGenerator.generate(Initiative__c.SObjectType),
                Type__c = 'Business Review',
                Name = 'Initiative 1',
                Start_Date__c = System.today().addDays(5),
                Account__c = accountList[0].Id,
                Status__c = 'Not Started'
            ),
            new Initiative__c(
                Id = fflib_IDGenerator.generate(Initiative__c.SObjectType),
                Type__c = 'Business Review',
                Name = 'Initiative 2',
                Start_Date__c = System.today().addDays(5),
                Account__c = accountList[1].Id,
                Status__c = 'Not Started'
            )
        };

        Product_Insights__c[] insightsList = new List<Product_Insights__c>{
            new Product_Insights__c(
                Initiative__c = initativeRec[0].Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested'
            ),
            new Product_Insights__c(
                Initiative__c = initativeRec[1].Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IInitiativesSelector selectorMock = (IInitiativesSelector) mocks.mock(
            IInitiativesSelector.class
        );

        mocks.startStubbing();

        mocks.when(selectorMock.SObjectType()).thenReturn(Initiative__c.SObjectType);
        mocks.when(selectorMock.selectByInsights(insightsList)).thenReturn(initativeRec);

        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);
        IProductInsights insightsInstance = ProductInsights.newInstance(insightsList);

        insightsInstance.autopopulateAccountOnInsights();
        System.assertNotEquals(
            null,
            insightsList[0].Account_Name__c,
            'The parent Account was not autopopulated at all'
        );
        System.assertNotEquals(
            null,
            insightsList[1].Account_Name__c,
            'The parent Account was not autopopulated at all'
        );
        System.assertEquals(
            accountList[0].Id,
            insightsList[0].Account_Name__c,
            'The parent Account was not autopopulated appropriately'
        );
        System.assertEquals(
            accountList[1].Id,
            insightsList[1].Account_Name__c,
            'The parent Account was not autopopulated appropriately'
        );
    }

    @isTest
    private static void testWhenInsightsAreInsertedThenOpportunityLookupUniquenessIsChecked() {
        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 2')
        };

        List<Opportunity> opportunitiesRec = new List<Opportunity>{
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[0].Id
            ),
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[1].Id,
                Opportunity_Sub_Type__c = 'Net New Partner'
            )
        };

        Campaign_Product__c campaignProducts = new Campaign_Product__c(
            Id = fflib_IDGenerator.generate(Campaign_Product__c.SObjectType),
            Product_Family__c = 'Marketplace',
            Status__c = 'Active',
            Name = 'Product Test'
        );

        Id insight1 = fflib_IDGenerator.generate(Product_Insights__c.SObjectType);
        Id insight2 = fflib_IDGenerator.generate(Product_Insights__c.SObjectType);
        Id insight3 = fflib_IDGenerator.generate(Product_Insights__c.SObjectType);
        Id insight4 = fflib_IDGenerator.generate(Product_Insights__c.SObjectType);

        Product_Insights__c[] insightsList = new List<Product_Insights__c>{
            new Product_Insights__c(
                Id = insight1,
                Opportunity__c = opportunitiesRec[0].Id,
                Product__c = campaignProducts.Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested'
            ),
            new Product_Insights__c(
                Id = insight2,
                Opportunity__c = opportunitiesRec[0].Id,
                Product__c = campaignProducts.Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested'
            )
        };

        Product_Insights__c[] newInsightsList = new List<Product_Insights__c>{
            new Product_Insights__c(
                Id = insight3,
                Opportunity__c = opportunitiesRec[0].Id,
                Product__c = campaignProducts.Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested'
            ),
            new Product_Insights__c(
                Id = insight4,
                Opportunity__c = opportunitiesRec[0].Id,
                Product__c = campaignProducts.Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IProductInsightsSelector selectorMock = (IProductInsightsSelector) mocks.mock(
            IProductInsightsSelector.class
        );

        mocks.startStubbing();

        mocks.when(selectorMock.SObjectType()).thenReturn(Product_Insights__c.SObjectType);
        mocks.when(selectorMock.selectAllInsightsWithLookups(new Set<Id>{ opportunitiesRec[0].Id }))
            .thenReturn(insightsList);

        mocks.stopStubbing();

        Application.Selector.setMock(selectorMock);
        IProductInsights insightsInstance = ProductInsights.newInstance(newInsightsList);

        insightsInstance.compareRecordsForUniqueCombinations();

        ApexPages.Message failureMessage = new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'This Solution is already added as Product Insight on the Opportunity. Please select a different Solution to add to the Product Insight.'
        );

        System.assertEquals(failureMessage, ApexPages.getMessages()[0], 'Message');
    }

    @isTest
    private static void testWhenNewInsightsAreInsertedThenOpportunityLookupUniquenessIsChecked() {
        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 2')
        };

        List<Opportunity> opportunitiesRec = new List<Opportunity>{
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[0].Id
            ),
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[1].Id,
                Opportunity_Sub_Type__c = 'Net New Partner'
            )
        };

        Campaign_Product__c campaignProducts = new Campaign_Product__c(
            Id = fflib_IDGenerator.generate(Campaign_Product__c.SObjectType),
            Product_Family__c = 'Marketplace',
            Status__c = 'Active',
            Name = 'Product Test'
        );

        Id insight1 = fflib_IDGenerator.generate(Product_Insights__c.SObjectType);
        Id insight2 = fflib_IDGenerator.generate(Product_Insights__c.SObjectType);
        Id insight3 = fflib_IDGenerator.generate(Product_Insights__c.SObjectType);

        Product_Insights__c[] insightsList = new List<Product_Insights__c>{
            new Product_Insights__c(
                Id = insight1,
                Opportunity__c = opportunitiesRec[0].Id,
                Product__c = campaignProducts.Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested'
            ),
            new Product_Insights__c(
                Id = insight2,
                Opportunity__c = opportunitiesRec[0].Id,
                Product__c = campaignProducts.Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested'
            )
        };

        Product_Insights__c[] newInsightsList = new List<Product_Insights__c>{
            new Product_Insights__c(
                Id = insight3,
                Opportunity__c = opportunitiesRec[1].Id,
                Product__c = campaignProducts.Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IProductInsightsSelector selectorMock = (IProductInsightsSelector) mocks.mock(
            IProductInsightsSelector.class
        );

        mocks.startStubbing();

        mocks.when(selectorMock.SObjectType()).thenReturn(Product_Insights__c.SObjectType);
        mocks.when(selectorMock.selectAllInsightsWithLookups(new Set<Id>{ opportunitiesRec[1].Id }))
            .thenReturn(insightsList);

        mocks.stopStubbing();

        Application.Selector.setMock(selectorMock);
        IProductInsights insightsInstance = ProductInsights.newInstance(newInsightsList);

        insightsInstance.compareRecordsForUniqueCombinations();

        System.assertEquals(0, ApexPages.getMessages().size(), 'Message');
    }

    @isTest
    private static void testWhenInsightsAreInsertedThenInitiativeLookupUniquenessIsChecked() {
        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 2')
        };

        List<Initiative__c> initativeRec = new List<Initiative__c>{
            new Initiative__c(
                Id = fflib_IDGenerator.generate(Initiative__c.SObjectType),
                Type__c = 'Business Review',
                Name = 'Initiative 1',
                Start_Date__c = System.today().addDays(5),
                Account__c = accountList[0].Id,
                Status__c = 'Not Started'
            ),
            new Initiative__c(
                Id = fflib_IDGenerator.generate(Initiative__c.SObjectType),
                Type__c = 'Business Review',
                Name = 'Initiative 2',
                Start_Date__c = System.today().addDays(5),
                Account__c = accountList[1].Id,
                Status__c = 'Not Started'
            )
        };

        Campaign_Product__c campaignProducts = new Campaign_Product__c(
            Id = fflib_IDGenerator.generate(Campaign_Product__c.SObjectType),
            Product_Family__c = 'Marketplace',
            Status__c = 'Active',
            Name = 'Product Test'
        );

        Id insight1 = fflib_IDGenerator.generate(Product_Insights__c.SObjectType);
        Id insight2 = fflib_IDGenerator.generate(Product_Insights__c.SObjectType);

        Product_Insights__c[] insightsList = new List<Product_Insights__c>{
            new Product_Insights__c(
                Id = insight1,
                Initiative__c = initativeRec[0].Id,
                Product__c = campaignProducts.Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested'
            ),
            new Product_Insights__c(
                Id = insight2,
                Initiative__c = initativeRec[0].Id,
                Product__c = campaignProducts.Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IProductInsightsSelector selectorMock = (IProductInsightsSelector) mocks.mock(
            IProductInsightsSelector.class
        );

        mocks.startStubbing();

        mocks.when(selectorMock.SObjectType()).thenReturn(Product_Insights__c.SObjectType);
        mocks.when(selectorMock.selectAllInsightsWithLookups(new Set<Id>{ initativeRec[0].Id }))
            .thenReturn(insightsList);

        mocks.stopStubbing();

        Application.Selector.setMock(selectorMock);

        IProductInsights insightsInstance = ProductInsights.newInstance(insightsList);

        insightsInstance.compareRecordsForUniqueCombinations();

        ApexPages.Message failureMessage = new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Product Insights must be unique for a given Initiative. Please update the existing Product Insight for this Campaign Product.'
        );

        System.assertEquals(failureMessage, ApexPages.getMessages()[0], 'Message');
    }

    @isTest
    private static void testWhenNewInsightsAreInsertedThenInitiativeLookupUniquenessIsChecked() {
        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 2')
        };

        List<Opportunity> opportunitiesRec = new List<Opportunity>{
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[0].Id
            ),
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[1].Id,
                Opportunity_Sub_Type__c = 'Net New Partner'
            )
        };

        Campaign_Product__c campaignProducts = new Campaign_Product__c(
            Id = fflib_IDGenerator.generate(Campaign_Product__c.SObjectType),
            Product_Family__c = 'Marketplace',
            Status__c = 'Active',
            Name = 'Product Test'
        );

        Id insight1 = fflib_IDGenerator.generate(Product_Insights__c.SObjectType);
        Id insight2 = fflib_IDGenerator.generate(Product_Insights__c.SObjectType);
        Id insight3 = fflib_IDGenerator.generate(Product_Insights__c.SObjectType);

        Product_Insights__c[] insightsList = new List<Product_Insights__c>{
            new Product_Insights__c(
                Id = insight1,
                Opportunity__c = opportunitiesRec[0].Id,
                Product__c = campaignProducts.Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested'
            ),
            new Product_Insights__c(
                Id = insight2,
                Opportunity__c = opportunitiesRec[0].Id,
                Product__c = campaignProducts.Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested'
            )
        };

        Product_Insights__c[] newInsightsList = new List<Product_Insights__c>{
            new Product_Insights__c(
                Id = insight3,
                Opportunity__c = opportunitiesRec[1].Id,
                Product__c = campaignProducts.Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IProductInsightsSelector selectorMock = (IProductInsightsSelector) mocks.mock(
            IProductInsightsSelector.class
        );

        mocks.startStubbing();

        mocks.when(selectorMock.SObjectType()).thenReturn(Product_Insights__c.SObjectType);
        mocks.when(selectorMock.selectAllInsightsWithLookups(new Set<Id>{ opportunitiesRec[1].Id }))
            .thenReturn(insightsList);

        mocks.stopStubbing();

        Application.Selector.setMock(selectorMock);
        IProductInsights insightsInstance = ProductInsights.newInstance(newInsightsList);

        insightsInstance.compareRecordsForUniqueCombinations();

        System.assertEquals(0, ApexPages.getMessages().size(), 'Message');
    }

    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        Account parentAccount = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType));
        Product_Insights__c[] insightsList = new List<Product_Insights__c>{
            new Product_Insights__c(
                Id = fflib_IDGenerator.generate(Product_Insights__c.SObjectType),
                Account_Name__c = parentAccount.Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested'
            ),
            new Product_Insights__c(
                Id = fflib_IDGenerator.generate(Product_Insights__c.SObjectType),
                Account_Name__c = parentAccount.Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested'
            )
        };

        //IProductInsights Instance Creation Call
        ProductInsights.newInstance(insightsList);

        //Default Constructor Call
        ProductInsights insightsObject = new ProductInsights(insightsList);

        //fflib_IDomainConstructor Call
        ProductInsights.Constructor constructorObject = new ProductInsights.Constructor();

        constructorObject.construct(insightsList);
        System.assertNotEquals(
            ProductInsights.newInstance(insightsList),
            insightsObject,
            'These obejct should not be similar'
        );
    }
}