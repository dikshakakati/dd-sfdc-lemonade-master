/**
 * @description
 * @author Deloitte
 * @date 22/04/2022
 */
public class NdaExpirationBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    static final String NDA_STATUS_EXPIRED = 'Expired';

    /**
     * @description Called to perform before update processing
     * @param bc Database.BatchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return AccountsSelector.newInstance().selectAccountsWithExpiredNda();
    }

    /**
     * @description Called to perform before update processing
     * @param batchableContextRef Database.BatchableContext
     * @param accountsExpired
     */
    public void execute(
        Database.BatchableContext batchableContextRef,
        List<Account> accountsExpired
    ) {
        for (Account eachExpiredAccount : accountsExpired) {
            eachExpiredAccount.NDA_Status__c = NDA_STATUS_EXPIRED;
        }

        fflib_ISObjectUnitOfWork accountUnitOfWork = Application.UnitOfWork.newInstance();
        accountUnitOfWork.registerDirty(accountsExpired);
        try {
            accountUnitOfWork.commitWork();
        } catch (Exception exp) {
            Logger.publish(LogEntry.newExceptionLog(exp, LogEntry.SeverityLevel.HIGH));
        }
    }

    /**
     * @description Called to perform before update processing if any
     * @param batchableContextRef Database.BatchableContext
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext batchableContextRef) {
    }

    /**
     * @description Execute method to schedule this batch class
     * @param sc
     */
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new NdaExpirationBatch(), 200);
    }
}