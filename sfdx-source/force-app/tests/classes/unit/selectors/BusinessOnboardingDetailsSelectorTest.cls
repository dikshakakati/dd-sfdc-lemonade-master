/**
 * @author Deloitte
 * @date 06/13/2024
 * @description Test class for BusinessOnboardingDetailsSelector class.
 */
@isTest(SeeAllData=false)
private class BusinessOnboardingDetailsSelectorTest {
    private static final String FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Mismatch in field list';
    private static final String OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: The object type must be Busines Onboarding Detail';

    /**
     * @description To test constructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        BusinessOnboardingDetailsSelector businessOnboardingInstance = new BusinessOnboardingDetailsSelector();
        Schema.SObjectType typeOfObject = businessOnboardingInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = businessOnboardingInstance.getSObjectFieldList();
        BusinessOnboardingDetailsSelector.newInstance();
        System.assertEquals(
            Schema.Business_Onboarding_Detail__c.SObjectType,
            typeOfObject,
            OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Business_Onboarding_Detail__c.Activated_Centrally_AC__c,
                Business_Onboarding_Detail__c.Mx_Requested_Photoshoot__c,
                Business_Onboarding_Detail__c.Order_Protocol__c,
                Business_Onboarding_Detail__c.Photoshoot_Date__c,
                Business_Onboarding_Detail__c.Photoshoot_Time__c,
                Business_Onboarding_Detail__c.Proposed_Date_of_Activation__c
            },
            sObjectFields,
            FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }
}