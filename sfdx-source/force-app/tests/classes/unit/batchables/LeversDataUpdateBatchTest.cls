/**
 * @author Deloitte
 * @date 07/01/2024
 * @description Test class for LeversDataUpdateBatchTest.
 */
@isTest(SeeAllData=false)
private class LeversDataUpdateBatchTest {
    private static final String ACCOUNT_PLAN_NAME = 'Account Plan';
    private static final String ACTIVE = 'Active';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_PREDICTED_INCREMENTAL_SALES = 'Unexpected Result: Mismatch for Predicted Incremental Sales Uplift $ Value.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_POINTS = 'Unexpected Result: Mismatch for Points Value.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected Result: The object type must be Lever.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_RECORD_LIST = 'Unexpected Result: The Levers were not appropriately fetched.';
    private static final String BUSINESS_ACCOUNT_NAME = 'Business Account';
    private static final String BUSINESS = 'Business';
    private static final String IN_PROGRESS = 'In Progress';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: There is a mismatch in fields list.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_NUMBER_OF_SOLUTIONS = 'Unexpected result: The number of solutions returned do not match the expected number of solutions.';
    private static final String METRIC = 'Marketing Revenue';
    private static final String CATEGORY = 'Discoverability';
    private static final String ADS_VALUE = 'Ads';
    private static final String ACTIVE_STATUS = 'Active';
    private static final String TYPE = 'Growth';
    private static final String VSP_CODE_VALUE = 'Test';
    private static final String ACCOUNT_NAME = 'Test Account';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String NEUTRAL = 'Neutral';
    private static final String PITCHING = 'Pitching';

   @isTest
    private static void testWhenBusinessAccountIdPassedThenReturnSolutionsWithPredictions() {
        Id accountId = Fake.generateId(Account.class);
        List<String> businessAccountIdList = new List<String>();
        businessAccountIdList.add(accountId);
        Id accountPlanId = Fake.generateId(Account_Plan__c.class);
        Id businessRecommendationId = Fake.generateId(Recommendation_Business__x.class);
        Id solutionId = Fake.generateId(Campaign_Product__c.class);
        Id leverId = Fake.generateId(Lever__c.class);
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id productInsightId = Fake.generateId(Product_Insights__c.class);
        Date currentQuarterStartDate;
        Date currentQuarterEndDate;
        Date todayDate= System.today();
        Integer currentQtr = Decimal.valueOf(todayDate.month()).divide(3.0, 0, System.RoundingMode.UP).intValue();
        Date startOfYear = date.newInstance(system.today().year(), 1, 1);
        if(currentQtr == 1) {
            currentQuarterStartDate = startOfYear;
        }else if(currentQtr == 2) {
            currentQuarterStartDate = startOfYear.addMonths(3);
        }else if(currentQtr == 3) {
            currentQuarterStartDate = startOfYear.addMonths(6);
        }else if(currentQtr == 4) {
            currentQuarterStartDate = startOfYear.addMonths(9);
        }
        currentQuarterEndDate = (currentQuarterStartDate.addMonths(3) - 1);

        Recommendation_Business__x businessRecommendation = (Recommendation_Business__x) new Fake(
                Recommendation_Business__x.class
            )
            .setField(Recommendation_Business__x.Id, businessRecommendationId)
            .setField(Recommendation_Business__x.Recommendation__c, ADS_VALUE)
            .setField(Recommendation_Business__x.incremental_sales__c, 123)
            .setField(Recommendation_Business__x.Business_Account__c, accountId)
            .setField(Recommendation_Business__x.Business_Account__r.Id, accountId)
            .setField(Recommendation_Business__x.Rank__c, 2)
            .setField(Recommendation_Business__x.points__c, 3)
            .setParent(
                            'Business_Account__r',
                            new Fake(Account.class)
                            .setField(Account.Id,accountId )
                        )
            .toSObject();


        Lever__c lever = (Lever__c) new Fake(Lever__c.class)
            .setField(Lever__c.Id, leverId)
            .setField(Lever__c.Status__c, ACTIVE_STATUS)
            .setField(Lever__c.Account__c, accountId)
            .setParent(
                            'Account__r',
                            new Fake(Account.class)
                            .setField(Account.Id,accountId )
             	)
            .setField(Lever__c.Predicted_Incremental_Sales__c, 100)
            .setField(Lever__c.Lever_Points__c, 1)
            .setParent(
                    'Account_Plan__r',
                    new Fake(Account_Plan__c.class)
                    .setField(Account_Plan__c.Id, accountPlanId)
                    .setField(Account_Plan__c.Name, ACCOUNT_PLAN_NAME)
                    .setField(Account_Plan__c.Account__c, accountId)
                    .setParent(
                        'Account__r',
                        new Fake(Account.class)
                        .setField(Account.Id,accountId )
                    	)
                    .setField(Account_Plan__c.Status__c, ACTIVE)
                )
            .setParent(
                'Solution__r',
                new Fake(Campaign_Product__c.class)
                .setField(Campaign_Product__c.Id, solutionId)
                .setField(Campaign_Product__c.VSP_Code__c, ADS_VALUE)
                .setField(Campaign_Product__c.Type__c, TYPE)
                .setField(Campaign_Product__c.Status__c, ACTIVE_STATUS)
                .setField(Campaign_Product__c.Rank__c, 2)
                .setField(Campaign_Product__c.Points__c, 2)
                .setField(Campaign_Product__c.Metric__c, METRIC)
                .setField(Campaign_Product__c.Category__c, CATEGORY)
                .setField(Campaign_Product__c.Name, ADS_VALUE)
                .setField(Campaign_Product__c.Number_of_Stores__c, 1)
                .setField(Campaign_Product__c.Product_Family__c, ADS_VALUE)
                .setField(Campaign_Product__c.IncrementalSales__c, 123)
            	)
                .toSObject();

		Product_Insights__c productInsight = (Product_Insights__c) new Fake(Product_Insights__c.class)
                .setField(Product_Insights__c.Id, productInsightId)
                .setField(Product_Insights__c.Interest_Level__c, NEUTRAL)
            	.setField(Product_Insights__c.Predicted_Sales_Uplift__c, 999)
                .setField(Product_Insights__c.Lever__c, leverId)
                .setParent(
                    'Lever__r',
                    new Fake(Lever__c.class)
                        .setField(Lever__c.Id, leverId)
                        .setField(Lever__c.Account__c, accountId)
						.setParent(
                            'Account__r',
                            new Fake(Account.class)
                            .setField(Account.Id,accountId)
             			)
                    	.setField(Lever__c.Solution__c, solutionId)
                        .setParent(
                        'Solution__r',
                            new Fake(Campaign_Product__c.class)
                            .setField(Campaign_Product__c.Id, solutionId)
                            .setField(Campaign_Product__c.VSP_Code__c, ADS_VALUE)
                            .setField(Campaign_Product__c.Type__c, TYPE)
                            .setField(Campaign_Product__c.Status__c, ACTIVE_STATUS)
                            .setField(Campaign_Product__c.Rank__c, 2)
                            .setField(Campaign_Product__c.Points__c, 2)
                            .setField(Campaign_Product__c.Metric__c, METRIC)
                            .setField(Campaign_Product__c.Category__c, CATEGORY)
                            .setField(Campaign_Product__c.Name, ADS_VALUE)
                            .setField(Campaign_Product__c.Number_of_Stores__c, 1)
                            .setField(Campaign_Product__c.Product_Family__c, ADS_VALUE)
                            .setField(Campaign_Product__c.IncrementalSales__c, 123)
            			)

                )
                .setField(Product_Insights__c.Opportunity__c, opportunityId)
            	.setParent(
                    'Opportunity__r',
                    new Fake(Opportunity.class)
                        .setField(Opportunity.Id, opportunityId)
                        .setField(Opportunity.StageName, PITCHING)
                        .setField(Opportunity.AccountId, accountId)
                    	.setField(Opportunity.IsClosed, False)
                )
                .toSobject();

        List<Lever__c> leversList = new List<Lever__c>{ lever };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ISolutionsSelector mocksSolutionsSelector = (ISolutionsSelector) mocks.mock(
            ISolutionsSelector.class
        );
        IBusinessRecommendationsSelector mocksBusinessRecommendationsSelector = (IBusinessRecommendationsSelector) mocks.mock(
            IBusinessRecommendationsSelector.class
        );
        LeversSelector mocksLeversSelector = (LeversSelector) mocks.mock(
            LeversSelector.class
        );
        ProductInsightsSelector mocksProductInsightsSelector = (ProductInsightsSelector) mocks.mock(
            ProductInsightsSelector.class
        );
        mocks.startStubbing();

        mocks.when(mocksSolutionsSelector.sObjectType())
            .thenReturn(Schema.Campaign_Product__c.SObjectType);

        mocks.when(mocksBusinessRecommendationsSelector.sObjectType())
            .thenReturn(Schema.Recommendation_Business__x.SObjectType);

  		mocks.when(mocksLeversSelector.sObjectType())
            .thenReturn(Schema.Lever__c.SObjectType);
        mocks.when(mocksProductInsightsSelector.sObjectType())
            .thenReturn(Schema.Product_Insights__c.SObjectType);

        mocks.when(
                mocksBusinessRecommendationsSelector.selectBusinessRecommendationsByBusinessAccountIds(
                    new List<String>{ accountId }
                )
            )
            .thenReturn(new List<Recommendation_Business__x>{ businessRecommendation });

        mocks.when(
                mocksSolutionsSelector.selectActiveSolutionsByVSPCodes()
            )
            .thenReturn(new List<Campaign_Product__c>());

        mocks.when(
                mocksLeversSelector.selectOpenLeversForCurrentQuarter(currentQuarterStartDate, currentQuarterEndDate)
            )
            .thenReturn(new List<Lever__c>{ lever });

        mocks.when(
            mocksProductInsightsSelector.selectProductInsightsByLeverIdWithOpenOpportunity(new Set<Id>{lever.Id})
            )
            .thenReturn(new List<Product_Insights__c>{ productInsight });

        mocks.stopStubbing();

        Application.SELECTOR.setMock(mocksBusinessRecommendationsSelector);
        Application.SELECTOR.setMock(mocksSolutionsSelector);
        Application.SELECTOR.setMock(mocksLeversSelector);
        Application.SELECTOR.setMock(mocksProductInsightsSelector);

        LeversDataUpdateBatch scheduler = new LeversDataUpdateBatch();
        scheduler.start(null);
        scheduler.execute(null, leversList);
        scheduler.finish(null);

        System.assertEquals(123, lever.Predicted_Incremental_Sales__c, ASSERT_MESSAGE_MISMATCH_IN_PREDICTED_INCREMENTAL_SALES);
        System.assertEquals(3, lever.Lever_Points__c, ASSERT_MESSAGE_MISMATCH_IN_POINTS);
        System.assertEquals(123, productInsight.Predicted_Sales_Uplift__c, ASSERT_MESSAGE_MISMATCH_IN_PREDICTED_INCREMENTAL_SALES);
    }

    @isTest
    static void testWhenBatchIsScheduledThenIncrementalSalesUpliftUpdated() {
        String cronExp = '0 0 1 * * ?';
        Test.startTest();
        String jobId = System.schedule(
            LeversDataUpdateBatchTest.class.getName(),
            cronExp,
            new LeversDataUpdateBatch()
        );
        Test.stopTest();
        CronTrigger cronTriggerRecord = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE Id = :jobId
        ];
        System.assertEquals(
            Time.newInstance(1, 0, 0, 0),
            cronTriggerRecord.NextFireTime.time(),
            'The Batch has not been triggered yet'
        );
    }
}