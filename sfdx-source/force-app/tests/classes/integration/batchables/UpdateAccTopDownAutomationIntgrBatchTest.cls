/**
 * @description Integration Test class for UpdateAccFieldsTopDownAutomationBatch
 * @author Deloitte
 * @date 05/23/2022
 */
@isTest
public class UpdateAccTopDownAutomationIntgrBatchTest {
    @isTest
    static void testWhenBatchisScheduledThenUpdateAccountAttributes() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Account parentAccount = new Account(
            Name = 'Ultimate Parent',
            RecordTypeId = businessRecordTypeId,
            Segment__c = 'Enterprise',
            Primary_Vertical__c = 'Gifts'
        );
        insert parentAccount;
        Account businessAccount = new Account(
            Name = 'Child Business Account',
            RecordTypeId = businessRecordTypeId,
            Segment__c = 'Mid-market',
            Primary_Vertical__c = 'Gifts',
            ParentId = parentAccount.Id,
            Ultimate_Parent_Account__c = parentAccount.Id
        );
        insert businessAccount;
        Account storeAccount = new Account(
            Name = 'Child Store Account',
            RecordTypeId = storeRecordTypeId,
            Segment__c = 'SMB',
            Primary_Vertical__c = 'Alcohol',
            ParentId = businessAccount.Id,
            Ultimate_Parent_Account__c = parentAccount.Id,
            BillingCountry = 'United States',
            BillingState = 'California',
            BillingCity = 'New Jersey',
            BillingStreet = 'ABC Street',
            BillingPostalCode = '12345'
        );
        insert storeAccount;

        Test.startTest();
        UpdateAccFieldsTopDownAutomationBatch batchObject = new UpdateAccFieldsTopDownAutomationBatch();
        Database.executeBatch(batchObject);
        Test.stopTest();

        List<Account> accountRecords = new List<Account>();
        accountRecords = [SELECT Segment__c, Primary_Vertical__c FROM Account];

        System.assertEquals(accountRecords[1].Segment__c, 'Enterprise', 'Incorrect Segment');
        System.assertEquals(accountRecords[2].Segment__c, 'Enterprise', 'Incorrect Segment');
    }

    @isTest
    static void testWhenBatchIsScheduledThenAccountIsUpdated() {
        String cronExp = '0 0 0 ? * SAT *';
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Account parentAccount = new Account(
            Name = 'Ultimate Parent',
            RecordTypeId = businessRecordTypeId,
            Segment__c = 'Enterprise',
            Primary_Vertical__c = 'Gifts'
        );
        insert parentAccount;
        Account storeAccount = new Account(
            Name = 'Child Store Account',
            RecordTypeId = storeRecordTypeId,
            Segment__c = 'SMB',
            Primary_Vertical__c = 'Alcohol',
            ParentId = parentAccount.Id,
            Ultimate_Parent_Account__c = parentAccount.Id,
            BillingCountry = 'United States',
            BillingState = 'California',
            BillingCity = 'New Jersey',
            BillingStreet = 'ABC Street',
            BillingPostalCode = '12345'
        );
        insert storeAccount;
        Test.startTest();
        String jobId = System.schedule(
            'TestVerticalAndSegmentTopsDown',
            cronExp,
            new UpdateAccFieldsTopDownAutomationBatch()
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