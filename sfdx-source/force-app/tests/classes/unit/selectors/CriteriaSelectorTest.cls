/**
 * @author Deloitte
 * @date 04/30/2024
 * @description Test class for CriteriaSelector class.
 */
@isTest(SeeAllData=false)
private class CriteriaSelectorTest {
    private static final String FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Mismatch in field list';
    private static final String OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: The object type must be Criterion.';

    /**
     * @description To test constructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        CriteriaSelector criteriaSelectorInstance = new CriteriaSelector();
        Schema.SObjectType typeOfObject = criteriaSelectorInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = criteriaSelectorInstance.getSObjectFieldList();
        CriteriaSelector.newInstance();
        System.assertEquals(
            Schema.Criterion__c.SObjectType,
            typeOfObject,
            OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Criterion__c.Comparator__c,
                Criterion__c.Name,
                Criterion__c.Criterion_Name__c,
                Criterion__c.Field__c,
                Criterion__c.Field_Reference_Type__c,
                Criterion__c.Integration_Template__c,
                Criterion__c.Service_Method_Name__c,
                Criterion__c.Value__c,
                Criterion__c.Work_Order_Template_Entry__c
            },
            sObjectFields,
            FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }
}