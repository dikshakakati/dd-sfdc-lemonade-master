/**
 * @author Deloitte
 * @date 19/05/2022
 * @description Batch Class that updates the Relationship Status between
 *              Account sharing a Relationship to Inactive, if the End Date
 *              has passed.
 */
public class AccountRelationshipExpirationBatch implements Database.Batchable<SObject>, Schedulable {
    private static final String RELATIONSHIP_STATUS_INACTIVE = 'Inactive';

    /**
     * @description Called to query all records with past End Dates
     * @param batchableContextRef Database.BatchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContextRef) {
        return new AccountRelationshipsSelector().selectActiveRelationshipsWithPastEndDates();
    }

    /**
     * @description Called to update the Relationship Status of Account Relationships
     *                to Inactive
     * @param batchableContextRef Database.BatchableContext
     * @param inactiveAccountRelationships
     */
    public void execute(
        Database.BatchableContext batchableContextRef,
        List<Account_Relationship__c> inactiveAccountRelationships
    ) {
        fflib_ISObjectUnitOfWork relationshipUnitOfWork = Application.UnitOfWork.newInstance();
        for (Account_Relationship__c eachInactiveRelationship : inactiveAccountRelationships) {
            eachInactiveRelationship.Relationship_Status__c = RELATIONSHIP_STATUS_INACTIVE;
            relationshipUnitOfWork.registerDirty(inactiveAccountRelationships);
        }
        try {
            relationshipUnitOfWork.commitWork();
        } catch (Exception changesFailedCommit) {
            Logger.publish(
                LogEntry.newExceptionLog(changesFailedCommit, LogEntry.SeverityLevel.HIGH)
            );
        }
    }

    /**
     * @description Operations to be performed after batch execution will be added here
     * @param batchableContextRef Database.BatchableContext
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext batchableContextRef) {
    }

    /**
     * @description Execute method to schedule this batch class
     * @param schedulableContext
     */
    public void execute(SchedulableContext schedulableContext) {
        Database.executeBatch(new AccountRelationshipExpirationBatch());
    }
}