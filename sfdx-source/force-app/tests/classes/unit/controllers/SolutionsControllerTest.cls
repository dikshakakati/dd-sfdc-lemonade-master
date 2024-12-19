/**
 * @author Deloitte
 * @date 06/13/2024
 * @description Test class for SolutionsController class.
 */
@isTest(SeeAllData=false)
private class SolutionsControllerTest {
    private static final String MISMATCH_ASSERT_MESSAGE = 'Unexpected result: Solution Id returned does not match the expected outcome.';
    private static final String METRIC = 'Marketing Revenue';
    private static final String CATEGORY = 'Discoverability';
    private static final String ADS_VALUE = 'Ads';
    private static final String ACTIVE_STATUS = 'Active';
    private static final String TYPE = 'Growth';
    /**
     * @description It is used to test when the Business Account Ids are passed it is returning its associated Solutions
     */
    @isTest
    private static void testWhenBusinessAccountIdPassedThenReturnSolutionsWithPredictions() {
        Id accountId = Fake.generateId(Account.class);
        List<String> businessAccountIdList = new List<String>();
        businessAccountIdList.add(accountId);
        Id accountPlanId = Fake.generateId(Account_Plan__c.class);
        Id businessRecommendationId = Fake.generateId(Recommendation_Business__x.class);
        Id solutionId = Fake.generateId(Campaign_Product__c.class);
		SolutionsController.CreateAccountPlanOrAddLeversInputVariables createLeverInputVariables;
        createLeverInputVariables = new SolutionsController.CreateAccountPlanOrAddLeversInputVariables();
		createLeverInputVariables.businessAccountIds = businessAccountIdList;
		createLeverInputVariables.accountPlanId = accountPlanId;
        List<SolutionsController.CreateAccountPlanOrAddLeversInputVariables> solutionControllerInputlist;
        solutionControllerInputlist =  new List<SolutionsController.CreateAccountPlanOrAddLeversInputVariables>();
        solutionControllerInputlist.add(createLeverInputVariables);
        Recommendation_Business__x businessRecommendation = (Recommendation_Business__x) new Fake(
                Recommendation_Business__x.class
            )
            .setField(Recommendation_Business__x.Id, businessRecommendationId)
            .setField(Recommendation_Business__x.Recommendation__c, ADS_VALUE)
            .setField(Recommendation_Business__x.incremental_sales__c, 123)
            .setField(Recommendation_Business__x.Business_Account__c, accountId)
            .setField(Recommendation_Business__x.Business_Account__r.Id, accountId)
            .setField(Recommendation_Business__x.Rank__c, 2)
            .setParent(
                            'Business_Account__r',
                            new Fake(Account.class)
                            .setField(Account.Id,accountId )
                        )
            .toSObject();

        Campaign_Product__c solution = (Campaign_Product__c) new Fake(Campaign_Product__c.class)
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
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ISolutionsSelector mocksSolutionsSelector = (ISolutionsSelector) mocks.mock(
            ISolutionsSelector.class
        );
        IBusinessRecommendationsSelector mocksBusinessRecommendationsSelector = (IBusinessRecommendationsSelector) mocks.mock(
            IBusinessRecommendationsSelector.class
        );

        mocks.startStubbing();
        mocks.when(mocksSolutionsSelector.sObjectType())
            .thenReturn(Schema.Campaign_Product__c.SObjectType);
        mocks.when(mocksBusinessRecommendationsSelector.sObjectType())
            .thenReturn(Schema.Recommendation_Business__x.SObjectType);

        mocks.when(
                mocksBusinessRecommendationsSelector.selectBusinessRecommendationsByBusinessAccountIds(
                    new List<String>{ accountId }
                )
            )
            .thenReturn(new List<Recommendation_Business__x>{ businessRecommendation });
        mocks.when(
                mocksSolutionsSelector.selectActiveSolutionsByVSPCodes()
            )
            .thenReturn(new List<Campaign_Product__c>{ solution });

        mocks.stopStubbing();

        Application.SELECTOR.setMock(mocksSolutionsSelector);
        Application.SELECTOR.setMock(mocksBusinessRecommendationsSelector);
        Test.startTest();
        List<AccountLeverEntry> results = SolutionsController.getSolutionsWithPredictionsByBusinessAccounts(
            solutionControllerInputlist
        );
        Test.stopTest();
        System.assertEquals(solutionId, results[0]?.solutions[0].Id, MISMATCH_ASSERT_MESSAGE);
    }

    /**
     * @description It is used to test when the Business Account Ids are passed it does not return associated Solutions
     */
    @isTest
    private static void testWhenBusinessAccountIdPassedThenReturnSolutionsWithoutPredictions() {
        Id accountId = Fake.generateId(Account.class);
        Id businessRecommendationId = Fake.generateId(Recommendation_Business__x.class);
		Id accountPlanId = Fake.generateId(Account_Plan__c.class);
        List<String> businessAccountIdList = new List<String>();
        businessAccountIdList.add(accountId);
        SolutionsController.CreateAccountPlanOrAddLeversInputVariables createLeverInputVariables;
        createLeverInputVariables = new SolutionsController.CreateAccountPlanOrAddLeversInputVariables();
		createLeverInputVariables.businessAccountIds = businessAccountIdList;
		createLeverInputVariables.accountPlanId = accountPlanId;
        List<SolutionsController.CreateAccountPlanOrAddLeversInputVariables> solutionControllerInputlist;
        solutionControllerInputlist =  new List<SolutionsController.CreateAccountPlanOrAddLeversInputVariables>();
        solutionControllerInputlist.add(createLeverInputVariables);
        Recommendation_Business__x businessRecommendation = (Recommendation_Business__x) new Fake(
                Recommendation_Business__x.class
            )
            .setField(Recommendation_Business__x.Id, businessRecommendationId)
            .setField(Recommendation_Business__x.Recommendation__c, 'ads')
            .setField(Recommendation_Business__x.incremental_sales__c, 123)
            .setField(Recommendation_Business__x.Business_Account__c, accountId)
            .setField(Recommendation_Business__x.Business_Account__r.Id, accountId)
            .setField(Recommendation_Business__x.Rank__c, 2)
            .setParent(
                            'Business_Account__r',
                            new Fake(Account.class)
                            .setField(Account.Id,accountId )
                        )
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ISolutionsSelector mocksSolutionsSelector = (ISolutionsSelector) mocks.mock(
            ISolutionsSelector.class
        );
        IBusinessRecommendationsSelector mocksBusinessRecommendationsSelector = (IBusinessRecommendationsSelector) mocks.mock(
            IBusinessRecommendationsSelector.class
        );

        mocks.startStubbing();
        mocks.when(mocksSolutionsSelector.sObjectType())
            .thenReturn(Schema.Campaign_Product__c.SObjectType);
        mocks.when(mocksBusinessRecommendationsSelector.sObjectType())
            .thenReturn(Schema.Recommendation_Business__x.SObjectType);

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

        mocks.stopStubbing();

        Application.SELECTOR.setMock(mocksSolutionsSelector);
        Application.SELECTOR.setMock(mocksBusinessRecommendationsSelector);

        Test.startTest();
        List<AccountLeverEntry> results = SolutionsController.getSolutionsWithPredictionsByBusinessAccounts(
            solutionControllerInputlist
        );
        Test.stopTest();
        System.assertEquals(0, results.size(), MISMATCH_ASSERT_MESSAGE);
    }
}