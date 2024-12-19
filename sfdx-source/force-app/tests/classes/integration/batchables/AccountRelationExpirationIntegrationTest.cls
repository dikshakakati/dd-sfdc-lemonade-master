/**
 * @author Deloitte
 * @date 19/05/2022
 * @description Integration Test class for AccountRelationshipExpirationBatch
 */
@isTest
public class AccountRelationExpirationIntegrationTest {
    @testSetup
    static void setupRelationshipData() {
        List<Account> accountList = new List<Account>{
            new Account(Name = 'Parent 1', Segment__c = 'Enterprise'),
            new Account(Name = 'Parent 2', Segment__c = 'Enterprise')
        };
        insert accountList;

        Account_Relationship__c inactiveRelationship = new Account_Relationship__c(
            Relationship_Type__c = 'Agency',
            Inverse_Relationship_Type__c = 'Agency',
            End_Date__c = Date.newInstance(2021, 3, 17),
            Account__c = accountList[0].Id,
            Relationship_Status__c = 'Active',
            Related_Account__c = accountList[1].Id
        );
        insert inactiveRelationship;

        Account_Relationship__c activeRelationship = new Account_Relationship__c(
            Relationship_Type__c = 'Merchant',
            Inverse_Relationship_Type__c = 'Merchant',
            End_Date__c = Date.today().addDays(2),
            Account__c = accountList[0].Id,
            Relationship_Status__c = 'Active',
            Related_Account__c = accountList[1].Id
        );
        insert activeRelationship;
    }

    @isTest
    static void testWhenAccountsWithExpiredEndDateThenUpdateStatus() {
        Test.startTest();
        AccountRelationshipExpirationBatch batchObject = new AccountRelationshipExpirationBatch();
        Database.executeBatch(batchObject);
        Test.stopTest();

        List<Account_Relationship__c> inActiveRelationships = [
            SELECT Id, Relationship_Status__c
            FROM Account_Relationship__c
            WHERE Relationship_Status__c = 'Inactive'
        ];
        List<Account_Relationship__c> activeRelationships = [
            SELECT Id, Relationship_Status__c
            FROM Account_Relationship__c
            WHERE Relationship_Status__c = 'Active'
        ];

        System.assertEquals(
            inActiveRelationships[0].Relationship_Status__c,
            'Inactive',
            'UnexpectedError: The Status was expected to be updated to Inactive but the Relationship is still Active.'
        );
        System.assertEquals(
            activeRelationships[0].Relationship_Status__c,
            'Active',
            'UnexpectedError: The Status was expected to remain Active'
        );
    }

    @isTest
    static void testWhenBatchIsScheduledThenStatusIsUpdated() {
        String cronExp = '0 0 1 * * ?';

        Test.startTest();
        String jobId = System.schedule(
            'TestStatusUpdateBatch',
            cronExp,
            new AccountRelationshipExpirationBatch()
        );
        Test.stopTest();

        CronTrigger cronTriggerRecord = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE Id = :jobId
        ];
        System.assertEquals(
            Time.newInstance(1, 0, 0, 0),
            cronTriggerRecord.NextFireTime.time(),
            'The Batch has not been triggered yet'
        );
    }
}