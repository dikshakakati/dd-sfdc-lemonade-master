/**
 * @description This batch class will update all the Stalled Opportunities to Closed if they haven’t been updated in more than 120 days or if the Close Date is in the past so that there is an incentive to continue managing a Stalled Opportunity.
 * @author Deloitte
 * @date 08/04/2022
 */
public class UpdateInactiveStalledOpportunitiesBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    private static final String UPDATE_INACTIVE_OPPO_BATCH_NUMBER_OF_DAYS_STATIC_CONFIG = 'Update_Inactive_Opp_Batch_Number_Of_Days';
    private Integer numberOfDays;

    /**
     * @description Default constructor to instantiate variables.
     */
    public UpdateInactiveStalledOpportunitiesBatch() {
        collectStaticConfigurations();
    }

    /**
     * @description Called to perform before update processing
     * @param bc Database.BatchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return OpportunitiesSelector.newInstance()
            .selectInactiveOpportunityInStalledStage(numberOfDays);
    }

    /**
     * @description Called to perform before update processing
     * @param batchableContextRef Database.BatchableContext
     * @param opportunityRecord
     */
    public void execute(
        Database.BatchableContext batchableContextRef,
        List<Opportunity> opportunityRecord
    ) {
        Map<Id, Opportunity> stalledOpportunitiesMap = new Map<Id, opportunity>(opportunityRecord);
        List<ContentDocumentLink> contentDocumentLinkRecord = ContentDocumentLinkSelector.newInstance()
            .selectNotesByLinkedEntityAndLastModifiedDate(
                stalledOpportunitiesMap.keyset(),
                numberOfDays
            );
        if (!contentDocumentLinkRecord.isEmpty()) {
            for (ContentDocumentLink eachContentDocumentLinkRecord : contentDocumentLinkRecord) {
                stalledOpportunitiesMap.remove(eachContentDocumentLinkRecord.LinkedEntityId);
            }
        }
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Opportunity> opportunityToUpdate = Opportunities.newInstance(
                stalledOpportunitiesMap.values()
            )
            .updateInactiveOpportunitiesInStalledStageToClosed();
        uow.registerDirty(opportunityToUpdate);
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
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
        Database.executeBatch(new UpdateInactiveStalledOpportunitiesBatch(), 200);
    }

    /**
     * @description It is used to get static configurations.
     */
    private void collectStaticConfigurations() {
        this.numberOfDays = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(UPDATE_INACTIVE_OPPO_BATCH_NUMBER_OF_DAYS_STATIC_CONFIG)
                .Configuration_Value__c
        );
    }
}