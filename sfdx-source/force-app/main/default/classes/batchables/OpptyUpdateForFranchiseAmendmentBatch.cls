/**
 * @author Deloitte
 * @date 19/08/2022
 * @description Batch class that updates all the opportunities where Nintex Use Case is populated
 * and other fields(Franchise Amendment Process, Opt-In/Opt-Out Response Time
 * (in Days), Responsible Party, Opt-Out Save Period (days)) are not populated.
 */
public class OpptyUpdateForFranchiseAmendmentBatch implements Database.Batchable<SObject>, Schedulable {
    /**
     * @description called to query all the Opportunities where Nintex Use Case field is not blank.
     * @param  batchableContextReference Database.BatchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContextReference) {
        return OpportunitiesSelector.newInstance()
            .selectOpportunitiesWithNintexUseCaseQueryLocator();
    }

    /**
     * @description called to update all the opportunities where Nintex Use Case is populated
     * and other fields(Franchise Amendment Process, Opt-In/Opt-Out Response Time
     * (in Days), Responsible Party, Opt-Out Save Period (days)) are not populated.
     * @param batchableContextReference Database.BatchableContext
     * @param opportunities
     */
    public void execute(
        Database.BatchableContext batchableContextReference,
        List<Opportunity> opportunities
    ) {
        if (!opportunities.isEmpty()) {
            OpportunitiesService.updateStageToClosedByFranchiseAmendmentProcessByBatch(
                opportunities
            );
        }
    }

    /**
     * @description Operations to be performed after batch execution will be added here
     * @param batchableContextReference Database.BatchableContext
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext batchableContextReference) {
    }

    /**
     * @description Execute method to schedule this batch class
     * @param schedulableContext
     */
    public void execute(schedulableContext schedulableContext) {
        Database.executeBatch(new OpptyUpdateForFranchiseAmendmentBatch());
    }
}