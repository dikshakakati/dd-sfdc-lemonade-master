/**
 * @description Test Class for OpportunityHandler
 * @author Deloitte
 */
@isTest
public with sharing class OpportunitiesTriggerTest {
    @isTest
    public static void testWhenDmlOccursThenTriggerFires() {
        Account parentAccount = new Account(Name = 'Test Account', Segment__c = 'Enterprise');
        insert parentAccount;

        //Create Product
        Product2 pro = new Product2(Name = 'Test Product');
        insert pro;

        //Instantiate the Pricebook2 record with StandardPricebookId
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );

        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        update standardPricebook;

        standardPricebook = [
            SELECT Id, IsStandard
            FROM Pricebook2
            WHERE Id = :standardPricebook.Id
        ];

        List<Opportunity> opportunitiesRec = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = parentAccount.Id,
                Pricebook2Id = standardPricebook.Id
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = parentAccount.Id,
                Opportunity_Sub_Type__c = 'Net New Partner',
                Pricebook2Id = standardPricebook.Id
            )
        };

        Test.startTest();
        insert opportunitiesRec;
        Test.stopTest();

        List<Opportunity> insertedOpportunities = [
            SELECT Id, Name
            FROM Opportunity
            WHERE AccountId = :parentAccount.id
        ];

        System.assertEquals(
            2,
            insertedOpportunities.size(),
            'Number of Opportunities do not match'
        );
    }
}