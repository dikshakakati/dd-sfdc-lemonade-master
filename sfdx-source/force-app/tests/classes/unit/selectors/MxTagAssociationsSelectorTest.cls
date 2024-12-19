/**
 * @author Deloitte
 * @date 28/02/2022
 * @description This is test class for MxTagAssociationsSelector class
 */
@isTest(seeAllData=false)
public class MxTagAssociationsSelectorTest {
    private static final String ACTIVE = 'Active';
    /**
     * @description This test method to query related MxTagAssociation of accounts.
     */
    @isTest
    private static void testWhenPassingBusinessAccountIdsThenGettingRelatedMxTagAssociations() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        List<Account> accounts = new List<Account>{
            new Account(
                name = 'TestAccount1',
                Segment__c = 'SMB',
                RecordTypeId = accRecordTypeBusiness
            ),
            new Account(
                name = 'TestAccount2',
                Segment__c = 'SMB',
                RecordTypeId = accRecordTypeBusiness
            ),
            new Account(
                name = 'TestAccount3',
                Segment__c = 'SMB',
                RecordTypeId = accRecordTypeBusiness
            )
        };
        insert accounts;
        //Pricebook2Id =standardPricebook,
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;

        List<Opportunity> opportunities = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Open',
                Pricebook2Id = standardPricebook.Id,
                Type = 'New',
                CloseDate = System.today(),
                AccountId = accounts[0].Id,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Estimated_Number_of_Stores__c = 1
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Open',
                Pricebook2Id = standardPricebook.Id,
                Type = 'New',
                CloseDate = System.today(),
                AccountId = accounts[1].Id,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Estimated_Number_of_Stores__c = 1
            ),
            new Opportunity(
                Name = 'Test3',
                StageName = 'Open',
                Pricebook2Id = standardPricebook.Id,
                Type = 'New',
                CloseDate = System.today(),
                AccountId = accounts[2].Id,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Estimated_Number_of_Stores__c = 1
            )
        };
        insert opportunities;

        List<Mx_Tag_Association__c> mxTagAssociations = new List<Mx_Tag_Association__c>{
            new Mx_Tag_Association__c(
                Account__c = accounts[0].Id,
                Opportunity__c = opportunities[0].Id
            ),
            new Mx_Tag_Association__c(
                Account__c = accounts[1].Id,
                Opportunity__c = opportunities[1].Id
            )
        };
        insert MxTagAssociations;

        Set<Id> accountIds = new Set<Id>{ accounts[0].Id, accounts[1].Id };
        MxTagAssociationsSelector mxTagAssociationInstance = new MxTagAssociationsSelector();

        List<Mx_Tag_Association__c> accountRelatedMxTagAssociations = mxTagAssociationInstance.selectByBusinessAccountIds(
            accountIds
        );
        System.assertEquals(2, accountRelatedMxTagAssociations.size(), 'The list size will match');
    }

    /**
     * @description This test method to query related MxTagAssociation of opportunities.
     */
    @isTest
    private static void testWhenPassingOpportunityIdsThenGettingRelatedMxTagAssociations() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        List<Account> accounts = new List<Account>{
            new Account(
                name = 'TestAccount1',
                Segment__c = 'SMB',
                RecordTypeId = accRecordTypeBusiness
            ),
            new Account(
                name = 'TestAccount2',
                Segment__c = 'SMB',
                RecordTypeId = accRecordTypeBusiness
            ),
            new Account(
                name = 'TestAccount3',
                Segment__c = 'SMB',
                RecordTypeId = accRecordTypeBusiness
            )
        };
        insert accounts;
        //Pricebook2Id =standardPricebook,
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;

        List<Opportunity> opportunities = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Open',
                Pricebook2Id = standardPricebook.Id,
                Type = 'New',
                CloseDate = System.today(),
                AccountId = accounts[0].Id,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Estimated_Number_of_Stores__c = 1
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Open',
                Pricebook2Id = standardPricebook.Id,
                Type = 'New',
                CloseDate = System.today(),
                AccountId = accounts[1].Id,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Estimated_Number_of_Stores__c = 1
            ),
            new Opportunity(
                Name = 'Test3',
                StageName = 'Open',
                Pricebook2Id = standardPricebook.Id,
                Type = 'New',
                CloseDate = System.today(),
                AccountId = accounts[2].Id,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Estimated_Number_of_Stores__c = 1
            )
        };
        insert opportunities;

        List<Mx_Tag_Association__c> mxTagAssociations = new List<Mx_Tag_Association__c>{
            new mx_Tag_Association__c(
                Account__c = accounts[0].Id,
                Opportunity__c = opportunities[0].Id
            ),
            new Mx_Tag_Association__c(
                Account__c = accounts[1].Id,
                Opportunity__c = opportunities[1].Id
            )
        };
        insert MxTagAssociations;

        Set<Id> opportunityIds = new Set<Id>{ opportunities[0].Id, opportunities[1].Id };
        MxTagAssociationsSelector mxTagAssociationInstance = new MxTagAssociationsSelector();

        List<Mx_Tag_Association__c> opportunityRelatedMxTagAssociations = mxTagAssociationInstance.selectByOpportunityIds(
            opportunityIds
        );
        System.assertEquals(
            4,
            opportunityRelatedMxTagAssociations.size(),
            'The list size will match'
        );
    }

    /**
     * @description To test Mx Top account are returned when business account Ids are passed.
     */
    @isTest
    private static void testWhenPassingBusinessAccountIdsThenGettingRelatedTopMxTagAssociations() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        List<Account> accounts = new List<Account>{
            new Account(
                name = 'TestAccount1',
                Segment__c = 'SMB',
                RecordTypeId = accRecordTypeBusiness
            ),
            new Account(
                name = 'TestAccount2',
                Segment__c = 'SMB',
                RecordTypeId = accRecordTypeBusiness
            ),
            new Account(
                name = 'TestAccount3',
                Segment__c = 'SMB',
                RecordTypeId = accRecordTypeBusiness
            )
        };
        insert accounts;
        List<MXTag__c> mxTags = new List<MXTag__c>{
            new MXTag__c(Name = 'Top MX', Name__c = 'Top MX', Status__c = 'Active'),
            new MXTag__c(Name = '', Status__c	= 'Active')
        };
        insert mxTags;
        List<Mx_Tag_Association__c> mxTagAssociations = new List<Mx_Tag_Association__c>{
            new Mx_Tag_Association__c(Account__c = accounts[0].Id, MXTag__c = mxTags[0].Id),
            new Mx_Tag_Association__c(Account__c = accounts[1].Id, MXTag__c = mxTags[1].Id)
        };
        insert MxTagAssociations;
        Set<Id> accountIds = new Set<Id>{ accounts[0].Id, accounts[1].Id };
        MxTagAssociationsSelector mxTagAssociationInstance = new MxTagAssociationsSelector();
        List<Mx_Tag_Association__c> accountRelatedMxTagAssociations = mxTagAssociationInstance.selectTopMXTagByBusinessAccountIds(
            accountIds
        );
        System.assertEquals(1, accountRelatedMxTagAssociations.size(), 'The list size will match');
    }
}