/**
 * @author Deloitte
 * @date 06/06/2024
 * @description Test class for Opportunity Creation Controller.
 */
@isTest(SeeAllData=false)
private class OpportunityCreationControllerTest {
    private static final String ADS_AND_PROMOS = 'Ads & Promos';
    private static final String ASSERT_MESSAGE = 'Unexpected Result: Mismatch in status';
    private static final String IN_PROGRESS = 'In Progress';
    private static final String BUSINESS_ACCOUNT_NAME = 'Business Account';
    private static final String UPGRADE = 'Upgrade';
    private static final String METRIC = 'Marketing Revenue';
    private static final String CATEGORY = 'Discoverability';
    private static final String ACTIVE_STATUS = 'Active';
    private static final String TYPE = 'Growth';
    private static final String VSP_CODE_VALUE = 'Test';
    private static final String ADS_VALUE = 'Ads';

    /**
     * @description It is used to test if Opportunity creation and Product Insight creation is
     * successful and if existing product insight exist, those should be reparented to the new opportunity.
     * Suppressed Warnings since mock verify method does not require System Assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenFlowInputsAreReceivedWithSolutionAndExistingProductInsightsThenOpportunityCreatedAndProductInsightReparented() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id leverId = fflib_IDGenerator.generate(Lever__c.SObjectType);
        Id accountPlanId = fflib_IDGenerator.generate(Account_Plan__c.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id opportunityIdExisting = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id solutionId = fflib_IDGenerator.generate(Campaign_Product__c.SObjectType);
        Id productInsightId = fflib_IDGenerator.generate(Product_Insights__c.SObjectType);

        Account accountRecord = new Account(Name = BUSINESS_ACCOUNT_NAME, Id = accountId);
        Lever__c leverRecord = (Lever__c) new Fake(Lever__c.class)
            .setField(Lever__c.Id, leverId)
            .setField(Lever__c.Account__c, accountRecord.Id)
            .setField(Lever__c.Account_Plan__c, accountPlanId)
            .setField(Lever__c.Solution__c, solutionId)
            .setField(Lever__c.Predicted_Incremental_Sales__c, 100)
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountRecord.Id)
                    .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
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

        Opportunity opportunityRecord = new Opportunity(
            Id = opportunityId,
            AccountId = accountRecord.Id,
            Account_Plan__c = accountPlanId,
            CloseDate = System.today().addDays(5),
            Opportunity_Sub_Type__c = ADS_AND_PROMOS
        );

        Product_Insights__c productInsightRecord = (Product_Insights__c) new Fake(
                Product_Insights__c.class
            )
            .setField(Product_Insights__c.Id, productInsightId)
            .setField(Product_Insights__c.Opportunity__c, opportunityIdExisting)
            .setField(Product_Insights__c.Lever__c, leverId)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        List<OpportunityCreationFlowInputs> flowInputs = new List<OpportunityCreationFlowInputs>();
        OpportunityCreationFlowInputs flowInput = new OpportunityCreationFlowInputs();
        flowInput.accountPlanId = accountPlanId;
        flowInput.levers = new List<Lever__c>{ leverRecord };
        flowInput.opportunityRecord = opportunityRecord;
        flowInputs.add(flowInput);

        ILeversSelector leversSelectorMock = (ILeversSelector) mocks.mock(LeversSelector.class);
        IProductInsightsSelector productInsightSelectorMock = (IProductInsightsSelector) mocks.mock(
            ProductInsightsSelector.class
        );
        mocks.startStubbing();
        mocks.when(leversSelectorMock.SObjectType()).thenReturn(Lever__c.SObjectType);
        mocks.when(leversSelectorMock.selectById(new Set<Id>{ leverId }))
            .thenReturn(new List<Lever__c>{ leverRecord });

        mocks.when(productInsightSelectorMock.SObjectType())
            .thenReturn(Product_Insights__c.SObjectType);
        mocks.when(
                productInsightSelectorMock.selectProductInsightsByLeverIdAndAccPlanId(
                    new Set<Id>{ leverId },
                    new Set<Id>{ accountPlanId }
                )
            )
            .thenReturn(new List<Product_Insights__c>{ productInsightRecord });
        mocks.stopStubbing();
        Application.Selector.setMock(leversSelectorMock);
        Application.Selector.setMock(productInsightSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        OpportunityCreationController.assignOpportunityNameForVSP(flowInputs);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Product_Insights__c.Opportunity__c => flowInput.opportunityRecord.Id
                    }
                )
            );
    }

    /**
     * @description It is used to test if Opportunity creation and Product Insight creation is
     * successful when Opportunity Sub type is Ads and Promos.
     */
    @isTest
    private static void testWhenFlowInputsAreReceivedForAdsAndPromosWithSolutionThenOpportunityAndProductInsightCreated() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id leverId = fflib_IDGenerator.generate(Lever__c.SObjectType);
        Id accountPlanId = fflib_IDGenerator.generate(Account_Plan__c.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id solutionId = fflib_IDGenerator.generate(Campaign_Product__c.SObjectType);
        Account accountRecord = new Account(Name = BUSINESS_ACCOUNT_NAME, Id = accountId);
        Lever__c leverRecord = (Lever__c) new Fake(Lever__c.class)
            .setField(Lever__c.Id, leverId)
            .setField(Lever__c.Account__c, accountRecord.Id)
            .setField(Lever__c.Account_Plan__c, accountPlanId)
            .setField(Lever__c.Solution__c, solutionId)
            .setField(Lever__c.Predicted_Incremental_Sales__c, 100)
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountRecord.Id)
                    .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            )
            .setParent(
                'Solution__r',
                new Fake(Campaign_Product__c.class)
                .setField(Campaign_Product__c.Id, solutionId)
                .setField(Campaign_Product__c.VSP_Code__c, ADS_AND_PROMOS)
                .setField(Campaign_Product__c.Type__c, TYPE)
                .setField(Campaign_Product__c.Status__c, ACTIVE_STATUS)
                .setField(Campaign_Product__c.Rank__c, 2)
                .setField(Campaign_Product__c.Points__c, 2)
                .setField(Campaign_Product__c.Metric__c, METRIC)
                .setField(Campaign_Product__c.Category__c, CATEGORY)
                .setField(Campaign_Product__c.Name, ADS_AND_PROMOS)
                .setField(Campaign_Product__c.Number_of_Stores__c, 1)
                .setField(Campaign_Product__c.Product_Family__c, ADS_AND_PROMOS)
                .setField(Campaign_Product__c.IncrementalSales__c, 123)
            )
            .toSObject();
        Opportunity opportunityRecord = new Opportunity(
            Id = opportunityId,
            AccountId = accountRecord.Id,
            CloseDate = System.today().addDays(5),
            Opportunity_Sub_Type__c = ADS_AND_PROMOS
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        List<OpportunityCreationFlowInputs> flowInputs = new List<OpportunityCreationFlowInputs>();
        OpportunityCreationFlowInputs flowInput = new OpportunityCreationFlowInputs();
        flowInput.accountPlanId = accountPlanId;
        flowInput.levers = new List<Lever__c>{ leverRecord };
        flowInput.opportunityRecord = opportunityRecord;
        flowInputs.add(flowInput);

        ILeversSelector leversSelectorMock = (ILeversSelector) mocks.mock(LeversSelector.class);
        mocks.startStubbing();
        mocks.when(leversSelectorMock.SObjectType()).thenReturn(Lever__c.SObjectType);
        mocks.when(leversSelectorMock.selectById(new Set<Id>{ leverId }))
            .thenReturn(new List<Lever__c>{ leverRecord });
        mocks.stopStubbing();
        Application.Selector.setMock(leversSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        OpportunityCreationController.assignOpportunityNameForVSP(flowInputs);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        System.assertEquals(leverRecord.Status__c, IN_PROGRESS, ASSERT_MESSAGE);
    }

    /**
     * @description It is used to test if Opportunity creation and Product Insight creation is
     * successful when Opportunity Sub type is Ads and Promos.
     */
    @isTest
    private static void testWhenFlowInputsAreReceivedForAdsAndPromosWithOutSolutionThenOpportunityAndProductInsightCreated() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id leverId = fflib_IDGenerator.generate(Lever__c.SObjectType);
        Id accountPlanId = fflib_IDGenerator.generate(Account_Plan__c.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Account accountRecord = new Account(Name = BUSINESS_ACCOUNT_NAME, Id = accountId);
        Lever__c leverRecord = (Lever__c) new Fake(Lever__c.class)
            .setField(Lever__c.Id, leverId)
            .setField(Lever__c.Account__c, accountRecord.Id)
            .setField(Lever__c.Account_Plan__c, accountPlanId)
            .setField(Lever__c.Predicted_Incremental_Sales__c, 100)
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountRecord.Id)
                    .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            )
            .toSObject();
        Opportunity opportunityRecord = new Opportunity(
            Id = opportunityId,
            AccountId = accountRecord.Id,
            CloseDate = System.today().addDays(5),
            Opportunity_Sub_Type__c = ADS_AND_PROMOS
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        List<OpportunityCreationFlowInputs> flowInputs = new List<OpportunityCreationFlowInputs>();
        OpportunityCreationFlowInputs flowInput = new OpportunityCreationFlowInputs();
        flowInput.accountPlanId = accountPlanId;
        flowInput.levers = new List<Lever__c>{ leverRecord };
        flowInput.opportunityRecord = opportunityRecord;
        flowInputs.add(flowInput);

        ILeversSelector leversSelectorMock = (ILeversSelector) mocks.mock(LeversSelector.class);
        mocks.startStubbing();
        mocks.when(leversSelectorMock.SObjectType()).thenReturn(Lever__c.SObjectType);
        mocks.when(leversSelectorMock.selectById(new Set<Id>{ leverId }))
            .thenReturn(new List<Lever__c>{ leverRecord });
        mocks.stopStubbing();
        Application.Selector.setMock(leversSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        OpportunityCreationController.assignOpportunityNameForVSP(flowInputs);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        System.assertEquals(leverRecord.Status__c, IN_PROGRESS, ASSERT_MESSAGE);
    }

    /**
     * @description It is used to test if Opportunity creation and Product Insight creation is
     * successful when Opportunity Sub type is Upgrade.
     */
    @isTest
    private static void testWhenFlowInputsAreReceivedForUpgradeWithOutSolutionThenOpportunityAndProductInsightCreated() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id leverId = fflib_IDGenerator.generate(Lever__c.SObjectType);
        Id accountPlanId = fflib_IDGenerator.generate(Account_Plan__c.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Account accountRecord = new Account(Name = BUSINESS_ACCOUNT_NAME, Id = accountId);
        Lever__c leverRecord = (Lever__c) new Fake(Lever__c.class)
            .setField(Lever__c.Id, leverId)
            .setField(Lever__c.Account__c, accountRecord.Id)
            .setField(Lever__c.Account_Plan__c, accountPlanId)
            .setField(Lever__c.Predicted_Incremental_Sales__c, 100)
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountRecord.Id)
                    .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            )
            .toSObject();
        Opportunity opportunityRecord = new Opportunity(
            Id = opportunityId,
            AccountId = accountRecord.Id,
            CloseDate = System.today().addDays(5),
            Opportunity_Sub_Type__c = UPGRADE
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        List<OpportunityCreationFlowInputs> flowInputs = new List<OpportunityCreationFlowInputs>();
        OpportunityCreationFlowInputs flowInput = new OpportunityCreationFlowInputs();
        flowInput.accountPlanId = accountPlanId;
        flowInput.levers = new List<Lever__c>{ leverRecord };
        flowInput.opportunityRecord = opportunityRecord;
        flowInputs.add(flowInput);
        ILeversSelector leversSelectorMock = (ILeversSelector) mocks.mock(LeversSelector.class);
        mocks.startStubbing();
        mocks.when(leversSelectorMock.SObjectType()).thenReturn(Lever__c.SObjectType);
        mocks.when(leversSelectorMock.selectById(new Set<Id>{ leverId }))
            .thenReturn(new List<Lever__c>{ leverRecord });
        mocks.stopStubbing();
        Application.Selector.setMock(leversSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        OpportunityCreationController.assignOpportunityNameForVSP(flowInputs);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        System.assertEquals(leverRecord.Status__c, IN_PROGRESS, ASSERT_MESSAGE);
    }

    /**
     * @description It is used to test if Opportunity creation and Product Insight creation is
     * successful when Opportunity Sub type is Upgrade.
     */
    @isTest
    private static void testWhenFlowInputsAreReceivedForUpgradeWithSolutionThenOpportunityAndProductInsightCreated() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id leverId = fflib_IDGenerator.generate(Lever__c.SObjectType);
        Id accountPlanId = fflib_IDGenerator.generate(Account_Plan__c.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
	Id solutionId = fflib_IDGenerator.generate(Campaign_Product__c.SObjectType);

        Account accountRecord = new Account(Name = BUSINESS_ACCOUNT_NAME, Id = accountId);
        Lever__c leverRecord = (Lever__c) new Fake(Lever__c.class)
            .setField(Lever__c.Id, leverId)
            .setField(Lever__c.Account__c, accountRecord.Id)
            .setField(Lever__c.Account_Plan__c, accountPlanId)
            .setField(Lever__c.Predicted_Incremental_Sales__c, 100)
            .setField(Lever__c.Solution__c, solutionId)
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, accountRecord.Id)
                    .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            )
            .setParent(
                'Solution__r',
                new Fake(Campaign_Product__c.class)
                .setField(Campaign_Product__c.Id, solutionId)
                .setField(Campaign_Product__c.VSP_Code__c, UPGRADE)
                .setField(Campaign_Product__c.Type__c, TYPE)
                .setField(Campaign_Product__c.Status__c, ACTIVE_STATUS)
                .setField(Campaign_Product__c.Rank__c, 2)
                .setField(Campaign_Product__c.Points__c, 2)
                .setField(Campaign_Product__c.Metric__c, METRIC)
                .setField(Campaign_Product__c.Category__c, CATEGORY)
                .setField(Campaign_Product__c.Name, UPGRADE)
                .setField(Campaign_Product__c.Number_of_Stores__c, 1)
                .setField(Campaign_Product__c.Product_Family__c, UPGRADE)
                .setField(Campaign_Product__c.IncrementalSales__c, 123)
            )
            .toSObject();
        Opportunity opportunityRecord = new Opportunity(
            Id = opportunityId,
            AccountId = accountRecord.Id,
            CloseDate = System.today().addDays(5),
            Opportunity_Sub_Type__c = UPGRADE
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        List<OpportunityCreationFlowInputs> flowInputs = new List<OpportunityCreationFlowInputs>();
        OpportunityCreationFlowInputs flowInput = new OpportunityCreationFlowInputs();
        flowInput.accountPlanId = accountPlanId;
        flowInput.levers = new List<Lever__c>{ leverRecord };
        flowInput.opportunityRecord = opportunityRecord;
        flowInputs.add(flowInput);
        ILeversSelector leversSelectorMock = (ILeversSelector) mocks.mock(LeversSelector.class);
        mocks.startStubbing();
        mocks.when(leversSelectorMock.SObjectType()).thenReturn(Lever__c.SObjectType);
        mocks.when(leversSelectorMock.selectById(new Set<Id>{ leverId }))
            .thenReturn(new List<Lever__c>{ leverRecord });
        mocks.stopStubbing();
        Application.Selector.setMock(leversSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        OpportunityCreationController.assignOpportunityNameForVSP(flowInputs);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        System.assertEquals(leverRecord.Status__c, IN_PROGRESS, ASSERT_MESSAGE);
    }
}
