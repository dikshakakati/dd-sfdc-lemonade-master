/**
 * @description Test class for ProductInsightsHandler
 * @author Deloitte
 * @date 06/04/2022
 */
@isTest(SeeAllData=false)
public class ProductInsightsHandlerTest {

    /**
     * @description SuppressWarnings are being used as the Handler is being used to perform
     *              calls to Domain methods and no updates are directly performed using the
     *              handler method.
     *              The suppress warning used helps bypass the PMD Rule error for mandatory
     *              assert statements for unit tests
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenInsightsAreInsertedThenBeforeInsertIsCalled() {
        //ARRANGE
        Account parentAccount = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType));
        Product_Insights__c[] newInsights = new List<Product_Insights__c>{
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

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IProductInsights insightsMocks = (IProductInsights) mocks.mock(IProductInsights.class);
        mocks.startStubbing();
        mocks.when(insightsMocks.getType()).thenReturn(Schema.Product_Insights__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(insightsMocks);

        fflib_SObjectDomain.Test.Database.onInsert(newInsights);
        fflib_SObjectDomain.triggerHandler(ProductInsightsHandler.class);

        //ACT
        ((IProductInsights) mocks.verify(insightsMocks, 1)).autopopulateAccountOnInsights();
        ((IProductInsights) mocks.verify(insightsMocks, 1)).compareRecordsForUniqueCombinations();
    }

    /**
     * @description SuppressWarnings are being used as the Handler is being used to perform
     *              calls to Domain methods and no updates are directly performed using the
     *              handler method.
     *              The suppress warning used helps bypass the PMD Rule error for mandatory
     *              assert statements for unit tests
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenInsightsAreUpdatedThenBeforeUpdateIsCalled() {
        //ARRANGE
        Account parentAccount = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType));
        Id productInsight1 = fflib_IDGenerator.generate(Product_Insights__c.SObjectType);
        Id productInsight2 = fflib_IDGenerator.generate(Product_Insights__c.SObjectType);
        Product_Insights__c[] oldInsights = new List<Product_Insights__c>{
            new Product_Insights__c(
                Id = productInsight1,
                Account_Name__c = parentAccount.Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested'
            ),
            new Product_Insights__c(
                Id = productInsight2,
                Account_Name__c = parentAccount.Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested'
            )
        };
        Product_Insights__c[] newInsights = new List<Product_Insights__c>{
            new Product_Insights__c(
                Id = productInsight1,
                Account_Name__c = parentAccount.Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested'
            ),
            new Product_Insights__c(
                Id = productInsight2,
                Account_Name__c = parentAccount.Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IProductInsights insightsMocks = (IProductInsights) mocks.mock(IProductInsights.class);
        mocks.startStubbing();
        mocks.when(insightsMocks.getType()).thenReturn(Schema.Product_Insights__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(insightsMocks);

        fflib_SObjectDomain.Test.Database.onUpdate(newInsights, new Map<Id, SObject>(oldInsights));
        fflib_SObjectDomain.triggerHandler(ProductInsightsHandler.class);

        //ACT
        ((IProductInsights) mocks.verify(insightsMocks, 1)).autopopulateAccountOnInsights();
        ((IProductInsights) mocks.verify(insightsMocks, 1)).compareRecordsForUniqueCombinations();
    }

    @isTest
    private static void testWhenInsightIsInsertedThenTriggerIsCalled() {
        //ARRANGE
        Account parentAccount = new Account(Name = 'Test Account ',Segment__c ='SMB');
        insert parentAccount;

        List<Campaign_Product__c> productRecords = new List<Campaign_Product__c>{
            new Campaign_Product__c(
                Name = 'Test Product 1',
                Product_Family__c = 'Ads',
                Status__c = 'Active'
            ),
            new Campaign_Product__c(
                Name = 'Test Product 2',
                Product_Family__c = 'Ads',
                Status__c = 'Active'
            )
        };
        insert productRecords;

        Product_Insights__c[] newInsights = new List<Product_Insights__c>{
            new Product_Insights__c(
                Account_Name__c = parentAccount.Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested',
                Product__c = productRecords[0].Id
            ),
            new Product_Insights__c(
                Account_Name__c = parentAccount.Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested',
                Product__c = productRecords[1].Id
            )
        };
        insert newInsights;

        System.assertNotEquals(null, newInsights[0].Id, 'The Record Id is null');
    }

    @isTest
    private static void testWhenClassInstantiatesThenCheck() {
        //Constructor call
        List<Product_Insights__c> insightsList = new List<Product_Insights__c>();
        ProductInsightsHandler insightsHandlerObject = new ProductInsightsHandler(insightsList);

        //Inner Class Constructor Call
        ProductInsightsHandler.Constructor objConstructor = new ProductInsightsHandler.Constructor();
        objConstructor.construct(insightsList);
        System.assertNotEquals(
            insightsHandlerObject,
            objConstructor.construct(insightsList),
            'The two constructs should not be similar'
        );
    }
}