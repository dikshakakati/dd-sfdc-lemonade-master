/**
 * @author Deloitte
 * @date 08/22/2024
 * @description Interface to add Selector class methods.
 */
public interface IInstantIngestionFieldMappingSelector extends fflib_ISObjectSelector {
    /**
     * @description Method fetches all Instant Ingestion field mapping records.
     * @return List<Inbound_Ingestion_Payload_Mapping__mdt> - returns list of metadata records
     */
    List<Inbound_Ingestion_Payload_Mapping__mdt> getAllValues();

    /**
     * @description It is used for getting the fields on Instant_Ingestor_Event_Binding__mdt.
     * @return List<Schema.SObjectField>- Instant_Ingestor_Event_Binding__mdt fields
     */
    List<Schema.SObjectField> getSObjectFieldList();
}