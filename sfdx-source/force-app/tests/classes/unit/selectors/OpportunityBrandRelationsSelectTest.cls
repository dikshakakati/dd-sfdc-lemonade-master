/**
 * @author Deloitte
 * @date 11/28/2022
 * @description Test Class for OpportunityBrandRelationships
 */
@isTest
private class OpportunityBrandRelationsSelectTest {
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

        Brand__c enterpriseBrand = new Brand__c(
            Brand_Owner__c = parentAccount.Id,
            Name = 'Enteprise Brand'
        );
        insert enterpriseBrand;

        Brand_Association__c eachBrandAssociation = new Brand_Association__c(
            Business_Account_Name__c = parentAccount.Id,
            Brand_Name__c = enterpriseBrand.Id
        );
        insert eachBrandAssociation;

        Set<Id> opportunityIds = new Set<Id>{ testEnterpriseOpportunity.Id, testSmbOpportunity.Id };

        Opportunity_Brand_Relationship__c testEntepriseOpportunityAccountRelationship = new Opportunity_Brand_Relationship__c(
            Opportunity__c = testEnterpriseOpportunity.Id,
            Brand__c = eachBrandAssociation.Id
        );
        insert testEntepriseOpportunityAccountRelationship;

        Opportunity_Brand_Relationship__c testSmbOpportunityAccountRelationship = new Opportunity_Brand_Relationship__c(
            Opportunity__c = testSmbOpportunity.Id,
            Brand__c = eachBrandAssociation.Id
        );
        insert testSmbOpportunityAccountRelationship;

        OpportunityBrandRelationshipsSelector relationshipSelectorInstance = new OpportunityBrandRelationshipsSelector();

        List<Opportunity_Brand_Relationship__c> opportunityAccountRelationships = relationshipSelectorInstance.selectByOpportunity(
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
        OpportunityBrandRelationshipsSelector relationshipSelectorInstance = new OpportunityBrandRelationshipsSelector();

        Schema.SObjectType typeOfObj = relationshipSelectorInstance.getSObjectType();
        List<Schema.SObjectField> fieldList = relationshipSelectorInstance.getSObjectFieldList();

        OpportunityBrandRelationshipsSelector.newInstance();

        System.assertEquals(
            Schema.Opportunity_Brand_Relationship__c.SObjectType,
            typeOfObj,
            'The object type must be Opportunity Account Relationship'
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Opportunity_Brand_Relationship__c.Id,
                Opportunity_Brand_Relationship__c.Opportunity__c,
                Opportunity_Brand_Relationship__c.Brand__c
            },
            fieldList,
            'Mismatch in field list'
        );
    }
    @isTest
    private static void testWhenOpportunityAndBrandIdPassedThenReturnMatchedData() {
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

        Brand__c enterpriseBrand = new Brand__c(
            Brand_Owner__c = parentAccount.Id,
            Name = 'Enteprise Brand'
        );
        insert enterpriseBrand;

        Brand_Association__c eachBrandAssociation = new Brand_Association__c(
            Business_Account_Name__c = parentAccount.Id,
            Brand_Name__c = enterpriseBrand.Id
        );
        insert eachBrandAssociation;

        Opportunity_Brand_Relationship__c testEntepriseOpportunityAccountRelationship = new Opportunity_Brand_Relationship__c(
            Opportunity__c = testEnterpriseOpportunity.Id,
            Brand__c = eachBrandAssociation.Id
        );
        insert testEntepriseOpportunityAccountRelationship;


        OpportunityBrandRelationshipsSelector relationshipSelectorInstance = new OpportunityBrandRelationshipsSelector();
        Test.startTest();
        List<Opportunity_Brand_Relationship__c> opportunityAccountRelationships0 = relationshipSelectorInstance.selectByOpportunityAndBrandAsscs(
            testEnterpriseOpportunity.Id, new Set<Id>{eachBrandAssociation.Id}
        );
        List<Opportunity_Brand_Relationship__c> opportunityAccountRelationships1 = relationshipSelectorInstance.selectByOpportunityAndBrandAsscs(
            testSmbOpportunity.Id, new Set<Id>{eachBrandAssociation.Id}
        );
        Test.stopTest();

        System.assertEquals(1, opportunityAccountRelationships0.size(),
        'expecting only 1 OBR');
        System.assertEquals(testEntepriseOpportunityAccountRelationship.Id, opportunityAccountRelationships0[0].Id,
        'not the expected OBR');

        System.assertEquals(0, opportunityAccountRelationships1.size(),
        'expecting no OBR"s');
    }
}