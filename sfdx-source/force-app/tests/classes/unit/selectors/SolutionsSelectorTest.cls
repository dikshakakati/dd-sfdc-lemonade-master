/**
 * @author Deloitte
 * @date 06/12/2024
 * @description Test class for SolutionsSelector class.
 */
@isTest(SeeAllData=false)
private class SolutionsSelectorTest {
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: There is a mismatch in fields list.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: The object type must be Event.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_NUMBER_OF_SOLUTIONS = 'Unexpected result: The number of solutions returned do not match the expected number of solutions.';
    private static final String METRIC = 'Marketing Revenue';
    private static final String CATEGORY = 'Discoverability';
    private static final String ADS_VALUE = 'Ads';
    private static final String ACTIVE_STATUS = 'Active';
    private static final String INACTIVE_STATUS = 'Inactive';
    private static final String TYPE = 'Growth';
    private static final String VSP_CODE_VALUE = 'Test';

    /**
     * @description To test contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        SolutionsSelector solutionsSelectorInstance = new SolutionsSelector();
        Schema.SObjectType typeOfObject = solutionsSelectorInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = solutionsSelectorInstance.getSObjectFieldList();
        SolutionsSelector.newInstance();
        System.assertEquals(
            Schema.Campaign_Product__c.SObjectType,
            typeOfObject,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Campaign_Product__c.Id,
                Campaign_Product__c.VSP_Code__c,
                Campaign_Product__c.Type__c,
                Campaign_Product__c.Status__c,
                Campaign_Product__c.Rank__c,
                Campaign_Product__c.Points__c,
                Campaign_Product__c.Metric__c,
                Campaign_Product__c.Category__c,
                Campaign_Product__c.Name,
                Campaign_Product__c.Number_of_Stores__c,
                Campaign_Product__c.Product_Family__c,
                Campaign_Product__c.IncrementalSales__c
            },
            sObjectFields,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }

    /**
     * @description To test when account ids passed then return the soltuions.
     */
    @isTest
    private static void testWhenAccountIdsPassedThenReturnSolutions() {
        Campaign_Product__c solution = new Campaign_Product__c();
        solution.VSP_Code__c = ADS_VALUE;
        solution.Type__c = TYPE;
        solution.Status__c = ACTIVE_STATUS;
        solution.Rank__c = 2;
        solution.Points__c = 2;
        solution.Metric__c = METRIC;
        solution.Category__c = CATEGORY;
        solution.Name = ADS_VALUE;
        solution.Number_of_Stores__c = 1;
        solution.Product_Family__c = ADS_VALUE;
        solution.IncrementalSales__c = 123;
        insert solution;
        Test.startTest();
        List<Campaign_Product__c> results = SolutionsSelector.newInstance()
            .selectActiveSolutionsByVSPCodes();
        Test.stopTest();
        System.assertEquals(1, results.size(), ASSERT_MESSAGE_MISMATCH_IN_NUMBER_OF_SOLUTIONS);
    }
    /**
     * @description To test when account ids passed then do not return the soltuions.
     */
    @isTest
    private static void testWhenAccountIdsPassedThenDoNotReturnSolutions() {
        Campaign_Product__c solution = new Campaign_Product__c();
        solution.VSP_Code__c = ADS_VALUE;
        solution.Type__c = TYPE;
        solution.Status__c = INACTIVE_STATUS;
        solution.Rank__c = 2;
        solution.Points__c = 2;
        solution.Metric__c = METRIC;
        solution.Category__c = CATEGORY;
        solution.Name = ADS_VALUE;
        solution.Number_of_Stores__c = 1;
        solution.Product_Family__c = ADS_VALUE;
        solution.IncrementalSales__c = 123;
        insert solution;
        Test.startTest();
        List<Campaign_Product__c> results = SolutionsSelector.newInstance()
            .selectActiveSolutionsByVSPCodes();
        Test.stopTest();
        System.assertEquals(0, results.size(), ASSERT_MESSAGE_MISMATCH_IN_NUMBER_OF_SOLUTIONS);
    }
}