/**
 * @author Deloitte
 * @date 06/12/2024
 * @description Test class for BusinessRecommendationsSelector class.
 */
@isTest(SeeAllData=false)
private class BusinessRecommendationsSelectorTest {
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: There is a mismatch in fields list.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: The object type must be Business Recommendation.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_NUMBER_OF_RECORDS = 'Unexpected result: There is a mismatch in records returned.';
    private static final String ACCOUNT_NAME = 'Test Account';
    private static final String SEGMENT_SMB = 'SMB';

    /**
     * @description To test contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        BusinessRecommendationsSelector businessRecommendationsSelectorInstance = new BusinessRecommendationsSelector();
        Schema.SObjectType typeOfObject = businessRecommendationsSelectorInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = businessRecommendationsSelectorInstance.getSObjectFieldList();
        BusinessRecommendationsSelector.newInstance();
        System.assertEquals(
            Schema.Recommendation_Business__x.SObjectType,
            typeOfObject,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Recommendation_Business__x.Id,
                Recommendation_Business__x.Recommendation__c,
                Recommendation_Business__x.incremental_sales__c,
                Recommendation_Business__x.Business_Account__c,
                Recommendation_Business__x.Rank__c,
                Recommendation_Business__x.points__c
            },
            sObjectFields,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }

    /**
     * @description It is to test when account ids passed the return associated Business recommendations records.
     * TODO: Add positive test method by exploring how to insert external objects.
     */
    @isTest
    private static void testWhenAccountIdsPassedThenDoNotReturnBusinessRecommendationRecords() {
        Account account = new Account(Name = ACCOUNT_NAME, Segment__c = SEGMENT_SMB);
        insert account;
        Test.startTest();
        List<Recommendation_Business__x> results = BusinessRecommendationsSelector.newInstance()
            .selectBusinessRecommendationsByBusinessAccountIds(
                new List<String>{ account.Id }
            );
        Test.stopTest();
        System.assertEquals(0, results.size(), ASSERT_MESSAGE_MISMATCH_IN_NUMBER_OF_RECORDS);
    }

}