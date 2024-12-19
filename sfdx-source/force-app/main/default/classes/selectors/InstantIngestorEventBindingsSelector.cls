/**
 * @author Deloitte
 * @date 05/14/2024
 * @description Selector Class for Instant Ingestor Event Binding custom metadata.
 */
public inherited sharing class InstantIngestorEventBindingsSelector extends fflib_SObjectSelector implements IInstantIngestorEventBindingsSelector {
    /**
     * @description Default constructor for the class.
     * @return IInstantIngestorEventBindingsSelector - interface of InstantIngestorEventBindingsSelector
     */
    public static IInstantIngestorEventBindingsSelector newInstance() {
        return (IInstantIngestorEventBindingsSelector) Application.Selector.newInstance(
            Instant_Ingestor_Event_Binding__mdt.SObjectType
        );
    }

    /**
     * @description Override default getSObjectType method.
     * @return SObjectType - object type of metadata
     */
    public Schema.SObjectType getSObjectType() {
        return Instant_Ingestor_Event_Binding__mdt.SObjectType;
    }

    /**
     * @description It is used for getting all field values for Instant_Ingestor_Event_Binding__mdt.
     * @return List<Instant_Ingestor_Event_Binding__mdt> - List of metadata records with values
     */
    public List<Instant_Ingestor_Event_Binding__mdt> getAllValues() {
        return Instant_Ingestor_Event_Binding__mdt.getAll().values();
    }

    /**
     * @description It is used for getting the fields of Instant_Ingestor_Event_Binding__mdt.
     * @return List<Schema.SObjectField>- Instant_Ingestor_Event_Binding__mdt fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Instant_Ingestor_Event_Binding__mdt.Topic__c,
            Instant_Ingestor_Event_Binding__mdt.Class_Name__c,
            Instant_Ingestor_Event_Binding__mdt.Scope_Size__c
        };
    }
}