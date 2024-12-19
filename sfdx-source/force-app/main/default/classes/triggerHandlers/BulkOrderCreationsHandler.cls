/**
 * @author Deloitte
 * @date 08/08/2024
 * @description Its is a handler class for BulkOrderCreations Trigger
 */
public with sharing class BulkOrderCreationsHandler extends ApplicationDomainHandler {

    /**
     * @description Constructor Method
     * @param sObjects
     */
    public BulkOrderCreationsHandler(List<Bulk_Order_Creation__e> sObjects) {
        super(sObjects);
        setContextBypass(Bulk_Order_Creation__e.SObjectType, BulkOrderCreationsHandler.class);
    }

    /**
     * @description It is invoked to perform after insert processing
     */
    public override void onAfterInsert() {
        invokeBulkOrderCreationBatchAfterInsert();
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjects
         * @return BulkOrderCreationsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjects) {
            return new BulkOrderCreationsHandler(sObjects);
        }
    }

    /**
     * @description It is used to collect the reference Ids and invoke BulkOrderCreation Batch
     */
    private void invokeBulkOrderCreationBatchAfterInsert() {
        Set<String> referenceIds = new Set<String>();
        for (Bulk_Order_Creation__e event : (List<Bulk_Order_Creation__e>) this.records)
        {
            referenceIds.add(event.Bulk_Order_Reference_Id__c );
        }
        if (!referenceIds.isEmpty()) {
            BulkOrderCreationBatch batch = new BulkOrderCreationBatch(referenceIds);
            Database.executeBatch(batch, Integer.valueOf(System.Label.Bulk_Order_Request_Batch_Size));
        }
    }
}