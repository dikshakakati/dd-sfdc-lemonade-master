/**
 * @description Integration Test class for NDA Expiration Batch
 * @author Deloitte
 * @date 29/04/2022
 */
@isTest
public class NdaExpirationBatchIntegrationTest {
    @isTest
    static void testWhenAccountsWithExpiredNDADateThenUpdateStatus() {
        Account expiredAccount = new Account(
            Name = 'Test Account Batch 1',
            NDA_Expiration_Date__c = Date.today() - 1,
            NDA_Status__c = 'Active',
            Segment__c = 'Enterprise'
        );
        insert expiredAccount;

        Test.startTest();
        NdaExpirationBatch batchObject = new NdaExpirationBatch();
        Database.executeBatch(batchObject);
        Test.stopTest();

        List<Account> accountList = new List<Account>();
        accountList = [SELECT Id, NDA_Status__c FROM Account];

        System.assertEquals(accountList[0].NDA_Status__c, 'Expired', 'Incorrect Status');
    }

    @isTest
    static void testWhenBatchIsScheduledThenStatusIsUpdated() {
        String cronExp = '0 0 0 3 9 ? *';

        Account expiredAccount = new Account(
            Name = 'Test Account Batch 1',
            NDA_Expiration_Date__c = Date.today() - 1,
            NDA_Status__c = 'Active',
            Segment__c = 'Enterprise'
        );
        insert expiredAccount;

        Test.startTest();
        String jobId = System.schedule(
            'TestNDAExpirationBatchSchedule',
            cronExp,
            new NdaExpirationBatch()
        );

        CronTrigger cronTriggerRecord = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE Id = :jobId
        ];

        Test.stopTest();

        System.assertEquals(
            0,
            cronTriggerRecord.TimesTriggered,
            'The Batch has not been triggered yet'
        );
    }
}