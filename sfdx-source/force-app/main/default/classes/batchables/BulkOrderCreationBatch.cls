/**
 * @author Deloitte
 * @date 08/08/2024
 * @description Batch class to create Parent ,Child and Merchant Work Orders for Bulk Requests
 * of Order Type Tablet, Marketing Kit or Photoshoot.
 */
public with sharing class BulkOrderCreationBatch implements Database.Batchable<sObject> {
    public Set<String> referenceIds;

    /**
     * @description Contructor to accept the Staging Bulk Reference Ids from Platform Event
     * @JIRA# LEM-15978
     * @param referenceIds
     */
	public BulkOrderCreationBatch(Set<String> referenceIds) {
        this.referenceIds = referenceIds;
    }

    /**
     * @description It queries all Bulk Order Request Records for the reference Id
     * @JIRA# LEM-15978
     * @param batchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return StagingBulkUploadRequestSelector.newInstance().selectStagingRequestsByReferenceIds(referenceIds);
    }

    /**
     * @description It creates Parent Work Order, Child Work Order and Merchant Orders
     * for tablet,Marketing Kit and Photoshoot Type of Bulk Requests
     * @JIRA# LEM-15978
     * @param batchableContext
     * @param stagingRequests
     */
    public void execute(
        Database.BatchableContext batchableContext,
        List<Staging_Bulk_Upload_Request__c> stagingRequests
    ) {
        BulkOrdersCreationService.createBulkParentAndChilOrders(stagingRequests);
    }

    /**
     * @description Finish method of this batch.
     * Suppressed Warnings since finish method is required to be implemented
     * but no logic is required to be processed in it.
     * @JIRA# LEM-15978
     * @param batchableContext
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext batchableContext) {
    }
}
