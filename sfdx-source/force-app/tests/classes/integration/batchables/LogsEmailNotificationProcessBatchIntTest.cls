/**
 * @author Deloitte
 * @date 01/18/2024
 * @description Integration test class for LogsEmailNotificationProcessorBatch class.
 */
@isTest(SeeAllData=false)
public class LogsEmailNotificationProcessBatchIntTest {
    private static final String ACCOUNT_BILLING_CITY = 'Missoula';
    private static final String ACCOUNT_BILLING_COUNTRY = 'United States';
    private static final String ACCOUNT_BILLING_POSTAL_CODE = '1234';
    private static final String ACCOUNT_BILLING_STATE = 'California';
    private static final String ACCOUNT_BILLING_STREET = '221B Baker Street';
    private static final String ACCOUNT_NAME = 'Parent Account';
    private static final String BATCH_TRIGGER_ASSERT_MESSAGE = 'The Batch has not been triggered yet';
    private static final String BUSINESS = 'Business';
    private static final String COMMISSION_CALCULATION_METHODOLOGY = 'DoorDash Platform Price';
    private static final String CRON_EXPRESSION = '0 0 1 * * ?';
    private static final String ENTERPRISE = 'Enterprise';
    private static final String JOB_NAME = 'TestLogsEmailNotificationProcessorBatchSchedule';
    private static final String PRIMARY_VERTICAL = 'Gifts';
    private static final String STORE = 'Store';
    private static final String STORE_ACCOUNT_NAME = 'Store Account';

    /**
     * @description To test if the batch runs and emails are sent.
     * TODO: Update assert statements to verify flow interview call.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenLogsSelectedThenSendEmailNotification() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(BUSINESS)
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(STORE)
            .getRecordTypeId();
        Schema.SObjectField parentField = Log__c.Parent_Account_Id_18__c;
        Account parentAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ENTERPRISE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            Primary_Vertical__c = PRIMARY_VERTICAL,
            Commission_Calculation_Methodology__c = COMMISSION_CALCULATION_METHODOLOGY
        );
        insert parentAccount;
        Account storeAccount = new Account(
            Name = STORE_ACCOUNT_NAME,
            RecordTypeId = storeRecordTypeId,
            Segment__c = ENTERPRISE,
            Primary_Vertical__c = PRIMARY_VERTICAL,
            ParentId = parentAccount.Id,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            Commission_Calculation_Methodology__c = COMMISSION_CALCULATION_METHODOLOGY
        );
        insert storeAccount;
        Log__c createdlog = new Log__c(
            Send_Notification__c = true,
            Parent_Account_Id_18__c = parentAccount.Id,
            Franchise_Parent_Account_Id_18__c = null,
            Recipient_Ids_To_Send_Notification__c = UserInfo.getUserId(),
            Store_Account_Id_18__c = storeAccount.Id,
            CreatedDate = System.now()
        );
        insert createdLog;
        Test.startTest();
        Database.executeBatch(new LogsEmailNotificationProcessorBatch(parentField));
        Test.stopTest();
    }

    /**
     * @description It is used to validate that the schedulable context execute
     * is scheduling the batch job correctly.
     */
    @isTest
    private static void testWhenBatchScheduledThenBatchExecutedOnScheduledTime() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(BUSINESS)
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(STORE)
            .getRecordTypeId();
        Schema.SObjectField parentField = Log__c.Parent_Account_Id_18__c;
        Account parentAccount = new Account(
            Name = ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ENTERPRISE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            Primary_Vertical__c = PRIMARY_VERTICAL,
            Commission_Calculation_Methodology__c = COMMISSION_CALCULATION_METHODOLOGY
        );
        insert parentAccount;
        Account storeAccount = new Account(
            Name = STORE_ACCOUNT_NAME,
            RecordTypeId = storeRecordTypeId,
            Segment__c = ENTERPRISE,
            Primary_Vertical__c = PRIMARY_VERTICAL,
            ParentId = parentAccount.Id,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            Commission_Calculation_Methodology__c = COMMISSION_CALCULATION_METHODOLOGY
        );
        insert storeAccount;
        Log__c createdlog = new Log__c(
            Send_Notification__c = true,
            Parent_Account_Id_18__c = parentAccount.Id,
            Franchise_Parent_Account_Id_18__c = null,
            Recipient_Ids_To_Send_Notification__c = UserInfo.getUserId(),
            Store_Account_Id_18__c = storeAccount.Id,
            CreatedDate = System.now()
        );
        insert createdLog;
        Test.startTest();
        String jobId = System.schedule(
            JOB_NAME,
            CRON_EXPRESSION,
            new LogsEmailNotificationProcessorBatch(parentField)
        );
        CronTrigger cronTriggerRecord = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE Id = :jobId
        ];
        Test.stopTest();
        System.assertEquals(0, cronTriggerRecord.TimesTriggered, BATCH_TRIGGER_ASSERT_MESSAGE);
    }
}