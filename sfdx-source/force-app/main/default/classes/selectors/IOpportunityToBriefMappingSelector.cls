/**
 * @author ATG
 * @date 10/03/2023
 * @description interface to add selector class methods
 */
public interface IOpportunityToBriefMappingSelector extends fflib_ISObjectSelector{
    /**
     * @description override default object type method
     * @return object type metadata
     */
    Schema.SObjectType getSObjectType();
    /**
     * @description Method to get all of the custom metadata records
     * @return List<Opportunity_To_Brief_Item_Mapping__mdt>
     */
    List<Opportunity_To_Brief_Item_Mapping__mdt> getAllValues();

    /**
     * @description Method that retrieves the field value mappings from the mdt
     * @return List<Schema.SObjectField> getSObjectFieldList()
     */
    List<Schema.SObjectField> getSObjectFieldList();
    /**
     * @description returns a list of Brief fields
     * @return List<Schema.SObjectField>
     */
    List<Schema.SObjectField> getBriefFieldsList();
    /**
     * @description returns a set of fields that are being used by the opportunity
     * @return Set<Schemea.SObjectField>
     */
    Set <Schema.SObjectField> getOpportunityFieldSet();
}