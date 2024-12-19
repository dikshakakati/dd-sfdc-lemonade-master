/**
 * @author Deloitte
 * @date 05/13/2024
 * @description Interface for Inbound_Ingestion_Log__c selector class methods.
 */
public interface IInboundIngestionLogsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used to get the Inbound Ingestion Logs by passed recordIds.
     * @param recordIds
     * @return List<Inbound_Ingestion_Log__c>
     */
    List<Inbound_Ingestion_Log__c> selectById(Set<Id> recordIds);

    /**
     * @description It is used to query parent Inbound Ingestion Log by passed UUIDs.
     * @param uuids
     * @return List<Inbound_ingestion_Log__c>
     */
    List<Inbound_ingestion_Log__c> selectParentInboundIngestionLogsByUUIDs(Set<String> uuids);

    /**
     * @description It is used to get the parent Inbound Ingestion Logs by passed unique
     * identifiers and integration type.
     * @param integrationTypes
     * @param uniqueIdentifiers
     * @return List<Inbound_Ingestion_Log__c>
     */
    List<Inbound_Ingestion_Log__c> selectInboundIngestionLogsByUniqueIdentifiers(
        Set<String> integrationTypes,
        Set<String> uniqueIdentifiers
    );

    /**
     * @description It is used to query the Inbound Ingestion Logs by passed unique identifiers
     * and integration type.
     * @param integrationTypes
     * @param uniqueIdentifiers
     * @return List<Inbound_Ingestion_Log__c>
     */
    List<Inbound_Ingestion_Log__c> selectInboundIngestionLogsByUUIDsAndIntegrationTypes(
        Set<String> integrationTypes,
        Set<String> uniqueIdentifiers
    );

    /**
     * @description It is used to query Inbound Ingestion Log by passed UUIDs.
     * @param uuids
     * @return List<Inbound_Ingestion_Log__c>
     */
    List<Inbound_Ingestion_Log__c> selectInboundIngestionLogsByUUIDs(Set<String> uuids);

    /**
     * @description Used to return failed ingestion parent logs
     * @param
     * @return Database.QueryLocator
     */
    Database.QueryLocator selectFailedIngestionLogs();

    /**
    * @description Query based on BizIds to return failed inbound ingestion logs
    * @author VenkateshDD | 10-03-2024
    * @param bizIds
    * @return List<Inbound_Ingestion_Log__c>
    **/
    List<Inbound_Ingestion_Log__c> selectFailedIngestionLogsByBizIds(
        Set<String> bizIds
    );

    /**
    * @description selects based on the uuid with the given statuses
    * @author VenkateshDD | 10-09-2024
    * @param uuids
    * @param statuses
    * @param source
    * @return List<Inbound_Ingestion_Log__c>
    **/
    List<Inbound_Ingestion_Log__c> selectByUUIDStatusSource(Set<String> uuids, Set<String> statuses, String source);

     /**
     * @description It is used to fetch ingestion log based on the integration type and source.
     * @return List<Inbound_Ingestion_Log__c>
     **/
    Database.QueryLocator selectSuccessIngestionLogsWithSSMOSourceORMxPortalNSEIntegrationType();
}