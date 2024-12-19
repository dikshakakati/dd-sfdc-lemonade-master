/**
 * @author ATG
 * @date 10/26/2023
 * @description Test class for Opportunity Brief RelationshipsSelector
 */
@isTest(SeeAllData=false)
private class OppBriefRelationshipsSelectorTest {
   /**
    * @description It is used to test the instantiation of OppBriefRelationshipsSelector class.
    */
    @isTest
    private static void testWhenOppBriefRelationshipsExistThenQueryBasedOnOpportunities(){
        OppBriefRelationshipsSelector relationshipsSelectorInstance = new OppBriefRelationshipsSelector();
        OppBriefRelationshipsSelector.newInstance();

        Schema.SObjectType typeOfObj = relationshipsSelectorInstance.getSObjectType();
        List<Schema.SObjectField> fieldList = relationshipsSelectorInstance.getSObjectFieldList();

        System.assertEquals(
            Schema.Opportunity_Brief_Relationship__c.SObjectType,
            typeOfObj,
            'The object type must be Opportunity Brief Relationship'
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Opportunity_Brief_Relationship__c.Id,
                Opportunity_Brief_Relationship__c.Brief__c,
                Opportunity_Brief_Relationship__c.Opportunity__c
            },
            fieldList,
            'Mismatch in field list'
        );
    }
}