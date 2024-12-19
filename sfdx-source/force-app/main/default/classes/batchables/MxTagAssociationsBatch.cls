/**
 * @author Deloitte
 * @date 09/04/2024
 * @description This batchable class to concatenate Active Mx Tag Associations associated with Business Accounts on Opportunities.
 */
public class MxTagAssociationsBatch implements Database.Batchable<SObject>, Schedulable {
    private static final String MXTAG_ASSOCIATION_BATCH_SIZE_STATIC_CONFIG = 'Mx_Tag_Associations_Batch_Size';
    /**
     * @description Called to get active Mx Tag Associations associated with Business Account
     * which are created/updated within last 24 hours.
     * @param batchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return new MxTagAssociationsSelector()
            .selectActiveMxTagAssociationsCreatedUpdatedInLast24Hours();
    }

    /**
     * @description Called to update Concatenated Active Mx Tag Associations onto Opportunity.
     * @param batchableContext
     * @param mxTagAssociations
     */
    public void execute(
        Database.BatchableContext batchableContext,
        List<Mx_Tag_Association__c> mxTagAssociations
    ) {
        OpportunitiesService.concatenateMxTagsOnSObjects(mxTagAssociations);
    }

    /**
     * @description Finish method to handle batch postprocessing.
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
        Database.executeBatch(
            new MxTagAssociationsBatch(),
            Integer.valueof(
                StaticConfigurationsSelector.newInstance()
                    .getInstanceValue(MXTAG_ASSOCIATION_BATCH_SIZE_STATIC_CONFIG)
                    .Configuration_Value__c
            )
        );
    }
}