/**
 * @author DoorDash
 * @date 03/25//2023
 * @description Hanlder class for Integration Request Object.
 */
public with sharing class IntegrationRequestsHandler extends ApplicationDomainHandler {
    private static final String INTEGRATION_TYPE_TABLET_CASE_SYNC = 'Tablet Case Sync';
    /**
     * @description default constructor method
     * @param sObjectList
     */
    public IntegrationRequestsHandler(List<Integration_request__c> sObjectList) {
        super(sObjectList);
        setContextBypass(Integration_request__c.SObjectType, IntegrationRequestsHandler.class);
    }
    /**
     * @description constructor Class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.Iconstructable {
        /**
         * @description this method implements construct class in fflib_SObjectDomain
         * @param sObjectList
         * @return IntegrationRequestsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new IntegrationRequestsHandler(sObjectList);
        }
    }
    /**
     * @description Called to perform processing during the after insert phase.
     */
    public override void onAfterInsert() {
        IntegrationRequestsService.updateParentIntRequest(
            new Map<Id, Integration_Request__c>(),
            (List<Integration_Request__c>) this.records
        );
        IntegrationRequestsService.publishEventsForProcessing(
            new Map<Id, Integration_Request__c>(),
            (List<Integration_Request__c>) this.records,
            false
        );
    }
    /**
     * @description Called to perform processing during the after insert phase.
     */
    public override void onBeforeInsert() {
        IntegrationRequests.newInstance(this.records).validateAndPrePopulateFields();
        IntegrationRequests.createLog(
            (List<Integration_request__c>) getRecordsByFieldValue(
                Integration_request__c.Integration_Type__c,
                INTEGRATION_TYPE_TABLET_CASE_SYNC
            )
        );
    }

    /**
     * @description Called to perform processing during the before update phase.
     * @param existingRecords
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        IntegrationRequests.createLog(
            (List<Integration_request__c>) getRecordsByFieldValue(
                Integration_request__c.Integration_Type__c,
                INTEGRATION_TYPE_TABLET_CASE_SYNC
            )
        );
    }

    /**
     * @description Called to sync the child ir status with parent ir status and publish events for pos requests.
     * @param existingRecords
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        IntegrationRequestsService.updateParentIntRequest(
            (Map<Id, Integration_Request__c>) existingRecords,
            (List<Integration_Request__c>) this.records
        );
        IntegrationRequestsService.publishEventsForProcessing(
            (Map<Id, Integration_Request__c>) existingRecords,
            (List<Integration_Request__c>) this.records,
            false
        );
    }
}