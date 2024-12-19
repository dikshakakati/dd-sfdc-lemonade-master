/**
 * @description MDS Sync Event Object Trigger Handler
 * @author Doordash
 * @date 02/27/2024
 */
public class MDSSyncEventsHandler extends ApplicationDomainHandler{
    /**
     * @description Constructor Method
     * @param sObjectList - MDSSyncEvents Record List
     */
    private static final String LOG_SERVICE_MDS_STORE_SYNC = 'MDS Store Sync';
    private static final String LOG_DOMAIN_NAME = 'Provisioning';
    public MDSSyncEventsHandler(List<MDS_Sync_Event__e> sObjectList) {
        super(sObjectList);
        setContextBypass(MDS_Sync_Event__e.SObjectType, MDSSyncEventsHandler.class);
    }
    /**
     * @description Constructor class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjectList - List of SObjects
         * @return MDSSyncEventsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new MDSSyncEventsHandler(sObjectList);
        }
    }
     /**
     * @description Called to perform after insert processing
     */
    public override void onAfterInsert(){
        Set<Id> integrationRequestIds = new Set<Id>();
        Set<String> integrationIdsString = new Set<String>();
        for(MDS_Sync_Event__e event: (List<MDS_Sync_Event__e>) this.records) {
            integrationIdsString.add(event.Integration_Request_Id__c);
            Id inetgrationRequestId = event.Integration_Request_Id__c;
            integrationRequestIds.add(inetgrationRequestId);
        }
        if(!integrationRequestIds.isEmpty()){
            try{
                MDSSyncEventsService.processMDSUpdates(integrationRequestIds);
            } catch(Exception e){
                GenericLoggerService.publish(GenericLoggerService.createGenericLog(LOG_SERVICE_MDS_STORE_SYNC,LOG_DOMAIN_NAME,GenericLogEntry.SeverityLevel.MEDIUM).logException(e).logSFRecordId(integrationIdsString));
            }

        }
    }
}