/**
 * @author Deloitte
 * @date 19/06/2022
 * @description Test Class for OpportunityAccountRelationshipsSelector
 */
@isTest
private class OpportunityAccountRelationsSelectTest {
    @isTest
    private static void testWhenParentOpportunitiesAreProvidedThenReturnChildRelationships() {
        Account parentAccount = new Account(Name = 'Parent Account', Segment__c = 'Enterprise');
        insert parentAccount;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;

        Opportunity testEnterpriseOpportunity = new Opportunity(
            Name = 'Test Enterprise Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today() + 1,
            AccountId = parentAccount.Id,
            Pricebook2Id = pricebookId
        );
        insert testEnterpriseOpportunity;

        Opportunity testSmbOpportunity = new Opportunity(
            Name = 'Test SMB Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today() + 1,
            AccountId = parentAccount.Id,
            Pricebook2Id = pricebookId
        );
        insert testSmbOpportunity;

        Set<String> opportunityIds = new Set<String>(
            new List<String>{ testEnterpriseOpportunity.Id, testSmbOpportunity.Id }
        );

        Opportunity_Account_Relationship__c testEntepriseOpportunityAccountRelationship = new Opportunity_Account_Relationship__c(
            Opportunity__c = testEnterpriseOpportunity.Id
        );
        insert testEntepriseOpportunityAccountRelationship;

        Opportunity_Account_Relationship__c testSmbOpportunityAccountRelationship = new Opportunity_Account_Relationship__c(
            Opportunity__c = testSmbOpportunity.Id
        );
        insert testSmbOpportunityAccountRelationship;

        OpportunityAccountRelationshipsSelector relationshipSelectorInstance = new OpportunityAccountRelationshipsSelector();

        List<Opportunity_Account_Relationship__c> opportunityAccountRelationships = relationshipSelectorInstance.fetchRelationshipsByParentOpportunities(
            opportunityIds
        );
        System.assertEquals(
            2,
            opportunityAccountRelationships.size(),
            'Unexpected Error: Relationships were not fetched correctly.'
        );
    }

    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        Opportunity_Account_Relationship__c testEntepriseOpportunityAccountRelationship = new Opportunity_Account_Relationship__c();

        OpportunityAccountRelationshipsSelector relationshipSelectorInstance = new OpportunityAccountRelationshipsSelector();

        List<Opportunity_Account_Relationship__c> relationships = relationshipSelectorInstance.selectById(
            new Set<Id>{ testEntepriseOpportunityAccountRelationship.Id }
        );
        Schema.SObjectType typeOfObj = relationshipSelectorInstance.getSObjectType();
        List<Schema.SObjectField> fieldList = relationshipSelectorInstance.getSObjectFieldList();

        OpportunityAccountRelationshipsSelector.newInstance();

        System.assertEquals(
            Schema.Opportunity_Account_Relationship__c.SObjectType,
            typeOfObj,
            'The object type must be Opportunity Account Relationship'
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Opportunity_Account_Relationship__c.Id,
                Opportunity_Account_Relationship__c.Name,
                Opportunity_Account_Relationship__c.Account__c,
                Opportunity_Account_Relationship__c.Opportunity__c,
                Opportunity_Account_Relationship__c.Related_Account__c
            },
            fieldList,
            'Mismatch in field list'
        );
        System.assert(
            relationships != null,
            'The list does not contain any Opportunity Account Relationships'
        );
    }
}