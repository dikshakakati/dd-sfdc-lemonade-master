/**
 * @author Deloitte
 * @date 04/24/2023
 * @description It is used to cleanup private Contacts created
 * through internal communication's flows for sending emails to Account Team Members.
 */
public with sharing class AccountTeamInternalContactsCleanupBatch implements Database.Batchable<SObject>, Schedulable {
    /**
     * @description It queries Contacts having Account Team Member Id value populated
     * to start the batch processing.
     * @JIRA# LEM-5727
     * @param batchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return ContactsSelector.newInstance().selectByAccountTeamMemberId();
    }

    /**
     * @description It initiates deletion of the passed Contacts.
     * @JIRA# LEM-5727
     * @param batchableContext
     * @param contacts
     */
    public void execute(Database.BatchableContext batchableContext, List<Contact> contacts) {
        SobjectDeletionService.fireRecordsDeletion(contacts);
    }

    /**
     * @description Finish method of this batch.
     * Suppressed Warnings since finish method is required to be implemented
     * but no logic is required to be processed in it.
     * @JIRA# LEM-5727
     * @param batchableContext
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext batchableContext) {
    }

    /**
     * @description Execute method to schedule this batch class.
     * @param schedulableContext
     */
    public void execute(SchedulableContext schedulableContext) {
        Database.executeBatch(new AccountTeamInternalContactsCleanupBatch(), 200);
    }
}