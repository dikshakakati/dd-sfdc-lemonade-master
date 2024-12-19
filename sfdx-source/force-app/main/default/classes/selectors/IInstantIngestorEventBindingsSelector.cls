/**
 * @author Deloitte
 * @date 05/14/2024
 * @description Interface to add Selector class methods.
 */
public interface IInstantIngestorEventBindingsSelector extends fflib_ISObjectSelector {
    /**
     * @description Method fetches all Instant Ingestor Event Binding records.
     * @return List<Instant_Ingestor_Event_Binding__mdt> - returns list of metadata records
     */
    List<Instant_Ingestor_Event_Binding__mdt> getAllValues();

    /**
     * @description It is used for getting the fields on Instant_Ingestor_Event_Binding__mdt.
     * @return List<Schema.SObjectField>- Instant_Ingestor_Event_Binding__mdt fields
     */
    List<Schema.SObjectField> getSObjectFieldList();
}