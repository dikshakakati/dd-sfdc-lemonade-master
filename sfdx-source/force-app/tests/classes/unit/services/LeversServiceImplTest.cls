/**
 * @description This is the test class for LeversServiceImpl
 * @author Deloitte
 * @date 13/06/2024
 */
@isTest
public with sharing class LeversServiceImplTest {
    private static final String ASSERT_MESSAGE_EXCEPTION_MESSAGE = 'Unexpected result: exception message is not matching';
    private static final String ACCOUNT_NAME = 'Business Account';
    private static final String MOCK_EXCEPTION_MESSAGE = 'Exception occurred while performing DML operation';
    private static final String NEEDS_ANALYSIS = 'Needs Analysis';
    private static final String NEUTRAL = 'Neutral';
    private static final String OPPORTUNITY_NAME = 'Test Opportunity';
    private static final String SCRIPT_THROWN_EXCEPTION = 'Script-thrown exception';

    /**
     * @description It is used to test if the Intrest level is updated on the Lever when the
     * Interest Level is updated on Product Insight
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenIntertestLevelUpdatedThenUpdateInterestLevelOnLever() {
        Id leverId = fflib_IDGenerator.generate(Lever__c.SObjectType);
        Id productInsightId = fflib_IDGenerator.generate(Product_Insights__c.SObjectType);
        List<Account> accountRecords = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = ACCOUNT_NAME)
        };
        List<Opportunity> opportunityRecords = new List<Opportunity>{
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = OPPORTUNITY_NAME,
                StageName = NEEDS_ANALYSIS,
                CloseDate = System.today().addDays(5),
                AccountId = accountRecords[0].Id
            )
        };
        Lever__c[] levers = new List<Lever__c>{
            new Lever__c(Id = leverId, Account__c = accountRecords[0].Id)
        };
        Product_Insights__c productInsightRecord = (Product_Insights__c) new Fake(
                Product_Insights__c.class
            )
            .setField(Product_Insights__c.Id, productInsightId)
            .setField(Product_Insights__c.Opportunity__c, opportunityRecords[0].Id)
            .setField(Product_Insights__c.Interest_Level__c, NEUTRAL)
            .setField(Product_Insights__c.Lever__c, leverId)
            .setParent(
                'Lever__r',
                new Fake(Lever__c.class)
                    .setField(Lever__c.Id, levers[0].Id)
                    .setField(Lever__c.Interest_Level__c, '')
                    .setField(Lever__c.Account__c, accountRecords[0].Id)
            )
            .toSobject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IProductInsightsSelector selectorMock = (IProductInsightsSelector) mocks.mock(
            IProductInsightsSelector.class
        );
        IGenericLogger genericLoggerService = (IGenericLogger) mocks.mock(GenericLoggerImpl.class);

        mocks.startStubbing();
        mocks.when(selectorMock.SObjectType()).thenReturn(Product_Insights__c.SObjectType);
        mocks.when(selectorMock.selectProductInsightsAndLeversById(new Set<Id>{ productInsightId }))
            .thenReturn(new List<Product_Insights__c>{ productInsightRecord });
        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);
        Application.UNITOFWORK.setMock(uowMock);
        Application.SERVICE.setMock(IGenericLogger.class, genericLoggerService);
        LeversService.updateInterestLevel(new List<Product_Insights__c>{ productInsightRecord });
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Lever__c.Id => leverId,
                        Lever__c.Interest_Level__c => NEUTRAL
                    }
                )
            );
    }

    /**
     * @description It is used to test if the Intrest level is updated on the Lever when the
     * exception is thrown.
     */
    @isTest
    private static void testWhenIntertestLevelUpdatedThenDoNotUpdateInterestLevelOnLever() {
        Id leverId = fflib_IDGenerator.generate(Lever__c.SObjectType);
        Id productInsightId = fflib_IDGenerator.generate(Product_Insights__c.SObjectType);
        List<Account> accountRecords = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = ACCOUNT_NAME)
        };
        List<Opportunity> opportunityRecords = new List<Opportunity>{
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = OPPORTUNITY_NAME,
                StageName = NEEDS_ANALYSIS,
                CloseDate = System.today().addDays(5),
                AccountId = accountRecords[0].Id
            )
        };
        Lever__c[] levers = new List<Lever__c>{
            new Lever__c(Id = leverId, Account__c = accountRecords[0].Id)
        };
        Product_Insights__c productInsightRecord = (Product_Insights__c) new Fake(
                Product_Insights__c.class
            )
            .setField(Product_Insights__c.Id, productInsightId)
            .setField(Product_Insights__c.Opportunity__c, opportunityRecords[0].Id)
            .setField(Product_Insights__c.Interest_Level__c, NEUTRAL)
            .setParent(
                'Lever__r',
                new Fake(Lever__c.class)
                    .setField(Lever__c.Id, levers[0].Id)
                    .setField(Lever__c.Interest_Level__c, '')
                    .setField(Lever__c.Account__c, accountRecords[0].Id)
            )
            .toSobject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IProductInsightsSelector selectorMock = (IProductInsightsSelector) mocks.mock(
            IProductInsightsSelector.class
        );
        IGenericLogger genericLoggerService = (IGenericLogger) mocks.mock(GenericLoggerImpl.class);

        mocks.startStubbing();
        mocks.when(selectorMock.SObjectType()).thenReturn(Product_Insights__c.SObjectType);
        mocks.when(selectorMock.selectProductInsightsAndLeversById(new Set<Id>{ productInsightId }))
            .thenReturn(new List<Product_Insights__c>{ productInsightRecord });
        ((fflib_ISObjectUnitOfWork) mocks.doThrowWhen(
                new TestCommitException(MOCK_EXCEPTION_MESSAGE),
                uowMock
            ))
            .commitWork();
        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);
        Application.UNITOFWORK.setMock(uowMock);
        Application.SERVICE.setMock(IGenericLogger.class, genericLoggerService);
        Test.startTest();
        String exceptionMessage;
        try {
            LeversService.updateInterestLevel(
                new List<Product_Insights__c>{ productInsightRecord }
            );
            ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
        } catch (Exception mockException) {
            exceptionMessage = mockException.getMessage();
        }
        Test.stopTest();
        System.assertEquals(
            MOCK_EXCEPTION_MESSAGE,
            exceptionMessage,
            ASSERT_MESSAGE_EXCEPTION_MESSAGE
        );
    }
}