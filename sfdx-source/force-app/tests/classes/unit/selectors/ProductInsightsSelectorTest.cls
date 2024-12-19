/**
 * @author Deloitte
 * @date 11/04/2022
 * @description This is test class for ProductInsightsSelector class
 */
@isTest
public class ProductInsightsSelectorTest {
    private static final String ASSERT_MESSAGE_MISMATCH_IN_RECORD_LIST = 'The retrieved list of Insight Records is incorrect';
    private static final String ASSERT_MESSAGE_LEVER_FIELD_MISMATCH = 'The Lever has not been fetched correctly';
    @isTest
    private static void testWhenAllInsightsAreQueriedThenAllRecordsAreRetrieved() {
        List<Account> accountList = new List<Account>{
            new Account(Name = 'Parent 1', Segment__c = 'Enterprise'),
            new Account(Name = 'Parent 2', Segment__c = 'Enterprise')
        };
        insert accountList;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;

        List<Opportunity> opportunitiesRec = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[0].Id,
                Pricebook2Id = pricebookId,
                Estimated_Number_of_Stores__c = 1
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[1].Id,
                Opportunity_Sub_Type__c = 'Net New Partner',
                Pricebook2Id = pricebookId,
                Estimated_Number_of_Stores__c = 1
            )
        };
        insert opportunitiesRec;

        Campaign_Product__c campaignProducts = new Campaign_Product__c(
            Product_Family__c = 'Marketplace',
            Status__c = 'Active',
            Name = 'Product Test'
        );
        insert campaignProducts;

        Product_Insights__c[] insightsList = new List<Product_Insights__c>{
            new Product_Insights__c(
                Opportunity__c = opportunitiesRec[0].Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested',
                Product__c = campaignProducts.Id
            ),
            new Product_Insights__c(
                Opportunity__c = opportunitiesRec[1].Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested',
                Product__c = campaignProducts.Id
            )
        };

        insert insightsList;

        List<Product_Insights__c> insights = new ProductInsightsSelector()
            .selectAllInsightsWithLookups(new Set<Id>{ opportunitiesRec[0].Id });

        System.assert(insights[0].Name != null, 'The name has not been auto - assigned');
        System.assertEquals(1, insights.size(), 'The Selector should return only one record');
        System.assertEquals(
            insightsList[0].Id,
            insights[0].Id,
            'The incorrect insight was returned'
        );
    }

    @isTest
    private static void testWhenIdIsSentThenReturnRecords() {
        List<Account> accountList = new List<Account>{
            new Account(Name = 'Parent 1', Segment__c = 'Enterprise'),
            new Account(Name = 'Parent 2', Segment__c = 'Enterprise')
        };
        insert accountList;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;

        List<Opportunity> opportunitiesRec = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[0].Id,
                Pricebook2Id = pricebookId,
                Estimated_Number_of_Stores__c = 1
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[1].Id,
                Opportunity_Sub_Type__c = 'Net New Partner',
                Pricebook2Id = pricebookId,
                Estimated_Number_of_Stores__c = 1
            )
        };
        insert opportunitiesRec;

        Campaign_Product__c campaignProducts = new Campaign_Product__c(
            Product_Family__c = 'Marketplace',
            Status__c = 'Active',
            Name = 'Product Test'
        );
        insert campaignProducts;

        Product_Insights__c[] insightsList = new List<Product_Insights__c>{
            new Product_Insights__c(
                Opportunity__c = opportunitiesRec[0].Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested',
                Product__c = campaignProducts.Id
            ),
            new Product_Insights__c(
                Opportunity__c = opportunitiesRec[1].Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested',
                Product__c = campaignProducts.Id
            )
        };

        insert insightsList;

        List<Product_Insights__c> insights = new ProductInsightsSelector()
            .selectById(new Set<Id>{ insightsList[0].Id, insightsList[1].Id });

        System.assertEquals(
            2,
            insights.size(),
            'The retrieved list of Insight Records is incorrect'
        );
        System.assertEquals(
            opportunitiesRec[1].Id,
            insights[1].Opportunity__c,
            'Incorrect Parent Opportunity'
        );
        System.assert(insights[0].Name != null, 'The name has not been auto - assigned');
        System.assert(insights[1].Name != null, 'The name has not been auto - assigned');
    }

    /**
     * @description It is used to test if the Product Insights are returned when Ids are passed.
     */
    @isTest
    private static void testWhenIdsPassedThenReturnProductInsights() {
        List<Account> accountList = new List<Account>{
            new Account(Name = 'Parent 1', Segment__c = 'SMB'),
            new Account(Name = 'Parent 2', Segment__c = 'SMB')
        };
        insert accountList;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;

        List<Opportunity> opportunityRecords = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[0].Id,
                Pricebook2Id = pricebookId,
                Estimated_Number_of_Stores__c = 1
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[1].Id,
                Opportunity_Sub_Type__c = 'Net New Partner',
                Pricebook2Id = pricebookId,
                Estimated_Number_of_Stores__c = 1
            )
        };
        insert opportunityRecords;

        Campaign_Product__c campaignProducts = new Campaign_Product__c(
            Product_Family__c = 'Marketplace',
            Status__c = 'Active',
            Name = 'Product Test'
        );
        insert campaignProducts;

        Product_Insights__c[] productInsights = new List<Product_Insights__c>{
            new Product_Insights__c(
                Opportunity__c = opportunityRecords[0].Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested',
                Product__c = campaignProducts.Id
            ),
            new Product_Insights__c(
                Opportunity__c = opportunityRecords[1].Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested',
                Product__c = campaignProducts.Id
            )
        };

        insert productInsights;

        List<Product_Insights__c> productInsightRecords = new ProductInsightsSelector()
            .selectProductInsightsAndLeversById(
                new Set<Id>{ productInsights[0].Id, productInsights[1].Id }
            );
        List<Product_Insights__c> productInsightRecs = new ProductInsightsSelector()
            .selectProductInsightsAndLeversById(new Set<Id>{});

        System.assertEquals(
            0,
            productInsightRecs.size(),
            'The retrieved list of Insight Records is incorrect'
        );
        System.assertEquals(
            2,
            productInsightRecords.size(),
            'The retrieved list of Insight Records is incorrect'
        );
        System.assertEquals(
            productInsightRecords[0].Interest_Level__c,
            'Neutral',
            'Mismatch in Interest Level'
        );
        System.assertEquals(
            productInsightRecords[1].Interest_Level__c,
            'Neutral',
            'Mismatch in Interest Level'
        );
    }

    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        ProductInsightsSelector insightsSelectorInstance = new ProductInsightsSelector();

        Schema.SObjectType typeOfObj = insightsSelectorInstance.getSObjectType();
        List<Schema.SObjectField> fieldList = insightsSelectorInstance.getSObjectFieldList();

        ProductInsightsSelector.newInstance();

        System.assertEquals(
            Schema.Product_Insights__c.SObjectType,
            typeOfObj,
            'The object type must be Opportunity'
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Product_Insights__c.Id,
                Product_Insights__c.Name,
                Product_Insights__c.Product__c,
                Product_Insights__c.Product__r.Name,
                Product_Insights__c.Opportunity__c,
                Product_Insights__c.Initiative__c
            },
            fieldList,
            'Mismatch in field list'
        );
    }

    /**
     * @description It is used to test if the Product Insights are returned when Opportunity Ids are passed.
     */
    @isTest
    private static void testWhenOpportunityIdsSentThenReturnRecords() {
        List<Account> accountRecords = new List<Account>{
            new Account(Name = 'Parent 1', Segment__c = 'SMB'),
            new Account(Name = 'Parent 2', Segment__c = 'SMB')
        };
        insert accountRecords;
        Account_Plan__c[] accountPlans = new List<Account_Plan__c>{
            new Account_Plan__c(
                Name = 'Test Account Plan',
                Account__c = accountRecords[0].Id,
                Status__c = 'Active'
            ),
            new Account_Plan__c(
                Name = 'Test Account Plan',
                Account__c = accountRecords[1].Id,
                Status__c = 'Active'
            )
        };
        insert accountPlans;
        Lever__c[] levers = new List<Lever__c>{
            new Lever__c(Account__c = accountRecords[0].Id, Account_Plan__c = accountPlans[0].Id),
            new Lever__c(Account__c = accountRecords[0].Id, Account_Plan__c = accountPlans[0].Id)
        };
        insert levers;
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;

        List<Opportunity> opportunityRecords = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountRecords[0].Id,
                Pricebook2Id = pricebookId,
                Estimated_Number_of_Stores__c = 1
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountRecords[1].Id,
                Opportunity_Sub_Type__c = 'Net New Partner',
                Pricebook2Id = pricebookId,
                Estimated_Number_of_Stores__c = 1
            )
        };
        insert opportunityRecords;

        Campaign_Product__c campaignProducts = new Campaign_Product__c(
            Product_Family__c = 'Marketplace',
            Status__c = 'Active',
            Name = 'Product Test'
        );
        insert campaignProducts;

        Product_Insights__c[] productInsightRecords = new List<Product_Insights__c>{
            new Product_Insights__c(
                Opportunity__c = opportunityRecords[0].Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested',
                Product__c = campaignProducts.Id,
                Lever__c = levers[0].Id
            ),
            new Product_Insights__c(
                Opportunity__c = opportunityRecords[1].Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested',
                Product__c = campaignProducts.Id,
                Lever__c = levers[1].Id
            )
        };

        insert productInsightRecords;

        List<Product_Insights__c> productInsights = new ProductInsightsSelector()
            .selectProductInsightsByOpportunityIds(
                new Set<Id>{ opportunityRecords[0].Id, opportunityRecords[1].Id }
            );
        List<Product_Insights__c> productInsightsRecord = new ProductInsightsSelector()
            .selectProductInsightsByLeverIdAndAccPlanId(
                new Set<Id>{ levers[0].Id },
                new Set<Id>{ accountPlans[0].Id }
            );

        System.assertEquals(2, productInsights.size(), ASSERT_MESSAGE_MISMATCH_IN_RECORD_LIST);
        System.assertEquals(
            productInsightsRecord[0].Lever__c,
            levers[0].Id,
            ASSERT_MESSAGE_LEVER_FIELD_MISMATCH
        );
    }
}