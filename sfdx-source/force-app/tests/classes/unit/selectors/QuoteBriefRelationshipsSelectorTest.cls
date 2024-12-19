/**
 * @author Deloitte
 * @date 12/23/20222
 * @description Test class for Quote Brief RelationshipsSelector.
 */
@isTest(SeeAllData=false)
private class QuoteBriefRelationshipsSelectorTest {
    /**
     * @description It is used to test the instantiation of QuoteBriefRelationshipsSelector class.
     */
    @isTest
    private static void testWhenQuoteBriefRelationshipsExistThenQueryBasedOnQuoteAndCampaign() {
        QuoteBriefRelationshipsSelector relationshipsSelectorInstance = new QuoteBriefRelationshipsSelector();
        QuoteBriefRelationshipsSelector.newInstance();

        Schema.SObjectType typeOfObj = relationshipsSelectorInstance.getSObjectType();
        List<Schema.SObjectField> fieldList = relationshipsSelectorInstance.getSObjectFieldList();

        System.assertEquals(
            Schema.Quote_Brief_Relationship__c.SObjectType,
            typeOfObj,
            'The object type must be Quote Brief Relationship'
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Quote_Brief_Relationship__c.Id,
                Quote_Brief_Relationship__c.Brief__c,
                Quote_Brief_Relationship__c.Campaign_of_Brief__c,
                Quote_Brief_Relationship__c.Quote__c,
                Quote_Brief_Relationship__c.Account__c
            },
            fieldList,
            'Mismatch in field list'
        );
    }
}