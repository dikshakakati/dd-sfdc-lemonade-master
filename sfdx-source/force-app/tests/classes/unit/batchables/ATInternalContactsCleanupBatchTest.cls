/**
 * @author Deloitte
 * @date 04/24/2023
 * @description Test class for AccountTeamInternalContactsCleanupBatch class.
 */
@isTest(SeeAllData=false)
private class ATInternalContactsCleanupBatchTest {
    private static final String ACCOUNT_TEAM_MEMBER_USER_ID = 'UniqueTestUserId';
    private static final String BATCH_NOT_TRIGGERED_ASSERT_MESSAGE = 'Unexpected result: Failed to trigger the batch.';
    private static final String CONTACT_EMAIL = 'ATInternalContactsCleanupBatchTest@test.com';
    private static final String CONTACT_FIRST_NAME = 'Sherlock';
    private static final String CONTACT_LAST_NAME = 'Holmes';
    private static final String CONTACT_MIDDLE_NAME = 'Scott';
    private static final String CONTACT_PHONE = '0987654321';
    private static final String CRON_EXPRESSION = '0 0 1 * * ?';
    private static final String SCHEDULED_JOB_NAME = AccountTeamInternalContactsCleanupBatch.class
        .getName();

    /**
     * @description To test deletion of Contacts (created through internal communication's flows
     * for sending emails to Account Team Members) when batch is executed.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountTeamMemberContactsExistsThenDeleteOnBatchExecution() {
        Contact accountTeamMemberContactMock = new Contact(
            Account_Team_Member_Id__c = ACCOUNT_TEAM_MEMBER_USER_ID,
            Email = CONTACT_EMAIL,
            FirstName = CONTACT_FIRST_NAME,
            LastName = CONTACT_LAST_NAME,
            MiddleName = CONTACT_MIDDLE_NAME,
            Phone = CONTACT_PHONE
        );
        insert accountTeamMemberContactMock;
        List<Contact> contactList = new List<Contact>{ accountTeamMemberContactMock };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        ContactsSelector contactSelectorMock = (ContactsSelector) mocks.mock(
            ContactsSelector.class
        );
        ISobjectDeletionService sObjectDeletionServiceMock = (ISobjectDeletionService) mocks.mock(
            ISobjectDeletionService.class
        );
        mocks.startStubbing();
        mocks.when(contactSelectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactSelectorMock.selectByAccountTeamMemberId()).thenReturn(null);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(contactSelectorMock);
        Application.SERVICE.setMock(ISobjectDeletionService.class, sObjectDeletionServiceMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);
        AccountTeamInternalContactsCleanupBatch internalContactsCleanupBatch = new AccountTeamInternalContactsCleanupBatch();
        internalContactsCleanupBatch.start(null);
        internalContactsCleanupBatch.execute(null, contactList);
        internalContactsCleanupBatch.finish(null);
        ((ISobjectDeletionService) mocks.verify(sObjectDeletionServiceMock, 1))
            .fireRecordsDeletion(contactList);
    }

    /**
     * @description To validate that schedulable context schedules the batch job correctly.
     **/
    @isTest
    private static void testWhenBatchScheduledThenBatchExecutedOnScheduledTime() {
        Test.startTest();
        String jobId = System.schedule(
            SCHEDULED_JOB_NAME,
            CRON_EXPRESSION,
            new AccountTeamInternalContactsCleanupBatch()
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
            BATCH_NOT_TRIGGERED_ASSERT_MESSAGE
        );
    }
}