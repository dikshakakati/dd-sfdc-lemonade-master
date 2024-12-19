/**
 * @author Deloitte
 * @date 09/15/2023
 * @description It is used to expire the approved Withholding Opt-out Franchise Form Request records
 * by updating the field 'Disable Mx Form Submission For This URL' to true where the corporate account's 'Number of Days to Opt-out' is 0.
 */
public class WithholdingFranchiseFormsExpirationBatch implements Database.Batchable<SObject>, Schedulable {
    /**
     * @description It is used to query the approved Withholding Opt-out Franchise Form Request records
     * where the 'Number of Days to Opt out' is 0 on the corporate Account.
     * @JIRA# LEM-9550
     * @param batchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return FranchiseFormRequestsSelector.newInstance()
            .selectApprovedWithholdingOptOutFranchiseFormsToExpire();
    }

    /**
     * @description It is used to perform an update on the approved Withholding Opt-out Franchise Form Request records to mark
     * the field 'Disable Mx Form Submission For This URL' to true in order to expire them.
     * @JIRA# LEM-9550
     * @param batchableContext
     * @param franchiseFormsToExpire
     */
    public void execute(
        Database.BatchableContext batchableContext,
        List<Merchant_Pop_Up_Response__c> franchiseFormsToExpire
    ) {
        FranchiseFormRequestsService.expireWithholdingOptOutFranchiseForms(franchiseFormsToExpire);
    }

    /**
     * @description Finish method of this batch.
     * Suppressed Warnings since finish method is required to be implemented
     * but no logic is required to be processed in it.
     * @JIRA# LEM-9550
     * @param batchableContext
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext batchableContext) {
    }

    /**
     * @description Execute method to schedule this batch class
     * @JIRA# LEM-9550
     * @param schedulableContext
     */
    public void execute(SchedulableContext schedulableContext) {
        Database.executeBatch(new WithholdingFranchiseFormsExpirationBatch());
    }
}