/**
 * @author Deloitte
 * @date 11/12/2024
 * @description This batchable class to update encrypted Cassie Id fields on Legacy Contacts.
 */
public class UpdateCassieIdOnLegacyContactsBatch implements Database.Batchable<SObject> {
    /**
     * @description It is used to get Contacts migrated for SMB where Cassie Id(s) are blank.
     * @param batchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return ContactsSelector.newInstance().selectLegacyContactsWithCassieIdsAsNull();
    }

    /**
     * @description It updates Cassie Id fields with encrypted value on the passed Contacts.
     * @JIRA# LEM-24364
     * @param batchableContext
     * @param contacts
     */
    public void execute(
        Database.BatchableContext batchableContext,
        List<Contact> contacts
    ) {
        ContactsService.updateEncryptedCassieIdFieldsOnMigratedContacts(contacts);
    }

    /**
     * @description Finish method to handle batch post-processing.
     * * Suppressed Warnings since finish method is required to be implemented
     * but no logic is required to be processed in it.
     * @param batchableContext
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext batchableContext) {
    }
}