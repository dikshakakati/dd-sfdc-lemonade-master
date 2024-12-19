/**
 * @author Deloitte
 * @date 04/26/2023
 * @description Integration test class for AccountTeamInternalContactsCleanupBatch class.
 */
@isTest(SeeAllData=false)
private class ATInternalContactsCleanupIntegrationTest {
    private static final string ASSERT_MESSAGE_CONTACTS_NOT_DELETED = 'Unexpected result: the internal contacts inserted were not deleted';
    private static final String ASSERT_MESSAGE_SCHEDULABLE_JOB = 'Unexpected result: Failed to schedule batch job';
    private static final string BUSINESS_ACCOUNT_NAME = 'Test Business Account';
    private static final string CONTACT_FIRSTNAME = 'Sherlock';
    private static final string CONTACT_LASTNAME = 'Holmes';
    private static final string CONTACT_EMAIL = 'ATInternalContactsCleanupIntegrationTest@test.com';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';

    /**
     * @description To test Account Team Member's private Contacts are cleaned up after batch is run.
     */
    @isTest
    private static void testWhenBatchRunThenAccountTeamMemberContactsDeleted() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert businessAccount;
        User driveSpecialistAccountTeamMember = TestDataFactory.createUser(false);
        insert driveSpecialistAccountTeamMember;
        Contact contact = new Contact(
            AccountId = businessAccount.Id,
            FirstName = CONTACT_FIRSTNAME,
            LastName = CONTACT_LASTNAME,
            Email = CONTACT_EMAIL,
            Account_Team_Member_Id__c = driveSpecialistAccountTeamMember.Id
        );
        insert contact;
        Test.setCreatedDate(contact.Id, System.today() - 4);
        AccountTeamInternalContactsCleanupBatch batchInstance = new AccountTeamInternalContactsCleanupBatch();
        Test.startTest();
        Database.executeBatch(batchInstance);
        Test.stopTest();
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = :CONTACT_EMAIL];
        System.assertEquals(0, contacts.size(), ASSERT_MESSAGE_CONTACTS_NOT_DELETED);
    }

    /**
     * @description To execute method of batch with SchedulableContext.
     */
    @isTest
    private static void testWhenBatchExecutedInSchedulableContextThenBatchScheduled() {
        String cronExpression = '0 30 3 * * ?';
        Test.startTest();
        String scheduledJobId = System.schedule(
            ATInternalContactsCleanupIntegrationTest.class.getName(),
            cronExpression,
            new AccountTeamInternalContactsCleanupBatch()
        );
        Test.stopTest();
        CronTrigger cronTriggerInstance = [
            SELECT Id, NextFireTime
            FROM CronTrigger
            WHERE Id = :scheduledJobId
        ];
        System.assertEquals(
            Time.newInstance(3, 30, 0, 0),
            cronTriggerInstance.NextFireTime.time(),
            ASSERT_MESSAGE_SCHEDULABLE_JOB
        );
    }
}