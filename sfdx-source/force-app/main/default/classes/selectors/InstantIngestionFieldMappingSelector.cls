/**
 * @author Deloitte
 * @date 08/22/2024
 * @description Selector Class for Instant Ingestor Field Mapping custom metadata.
 */
public inherited sharing class InstantIngestionFieldMappingSelector extends fflib_SObjectSelector implements IInstantIngestionFieldMappingSelector {
    /**
     * @description Default constructor for the class.
     * @return IInstantIngestionFieldMappingSelector - interface of InstantIngestionFieldMappingSelector
     */
    public static IInstantIngestionFieldMappingSelector newInstance() {
        return (IInstantIngestionFieldMappingSelector) Application.Selector.newInstance(
            Inbound_Ingestion_Payload_Mapping__mdt.SObjectType
        );
    }

    /**
     * @description Override default getSObjectType method.
     * @return SObjectType - object type of metadata
     */
    public Schema.SObjectType getSObjectType() {
        return Inbound_Ingestion_Payload_Mapping__mdt.SObjectType;
    }

    /**
     * @description It is used for getting all field values for Inbound_Ingestion_Payload_Mapping__mdt.
     * @return List<Inbound_Ingestion_Payload_Mapping__mdt> - List of metadata records with values
     */
    public List<Inbound_Ingestion_Payload_Mapping__mdt> getAllValues() {
        return Inbound_Ingestion_Payload_Mapping__mdt.getAll().values();
    }

    /**
     * @description It is used for getting the fields of Inbound_Ingestion_Payload_Mapping__mdt.
     * @return List<Schema.SObjectField>- Inbound_Ingestion_Payload_Mapping__mdt fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Inbound_Ingestion_Payload_Mapping__mdt.Integration_Type__c,
            Inbound_Ingestion_Payload_Mapping__mdt.Object__c,
            Inbound_Ingestion_Payload_Mapping__mdt.Default_Value__c,
			Inbound_Ingestion_Payload_Mapping__mdt.Field_Name__c,
			Inbound_Ingestion_Payload_Mapping__mdt.Payload_Attribute__c , 
			Inbound_Ingestion_Payload_Mapping__mdt.Payload_Type__c,
			Inbound_Ingestion_Payload_Mapping__mdt.Attribute_Key__c

        };
    }
}