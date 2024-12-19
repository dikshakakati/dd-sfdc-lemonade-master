/**
 * @description Interface for the ApplicationBindingsSelector
 * @author Scott McClung
 */
public interface IApplicationBindingsSelector extends fflib_ISObjectSelector {
    /**
     * @description Returns a map containing custom metadata records for the specific custom metadata type.
     * The map keys are the record DeveloperNames and the map values are the record sObjects.
     * @return Map<String, ApplicationBinding__mdt> - Custom metadata records
     */
    Map<String, ApplicationBinding__mdt> getAll();

    /**
     * @description Returns a list of all Application Binding records
     * @return List<ApplicationBinding__mdt> - returns list of metadata records
     */
    List<ApplicationBinding__mdt> getAllValues();

    /**
     * @description Returns a single custom metadata type record sObject for a specified record Id, DeveloperName, or API name.
     * @param idOrName
     * @return ApplicationBinding__mdt - Single record
     */
    ApplicationBinding__mdt getInstance( String idOrName );

    /**
     * @description This method is for getting the fields on ApplicationBinding__mdt
     * @return List<Schema.SObjectField>- ApplicationBinding__mdt fields
     */
    List<Schema.SObjectField> getSObjectFieldList();
}