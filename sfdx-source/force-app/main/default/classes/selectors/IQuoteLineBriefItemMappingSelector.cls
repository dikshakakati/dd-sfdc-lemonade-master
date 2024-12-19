/**
 * @author ATG
 * @date 09/27/2023
 * @description Interface to add selector class methods
 */
public interface IQuoteLineBriefItemMappingSelector extends fflib_ISObjectSelector{
    /**
     * @description Method to get all of the custom metadata records
     * @return List<Quote_Line_to_Brief_Item_Mapping__mdt>
     */
    List<Quote_Line_to_Brief_Item_Mapping__mdt> getAllValues();
    /**
     * @description override default object type method
     * @return object type metadata
     */
    Schema.SObjectType getSObjectType();

    /**
     * @description Method that retrieves the field value mappings from the mdt
     * @return List<Schema.SObjectField> getSObjectFieldList()
     */
    List<Schema.SObjectField> getSObjectFieldList();

    /**
     * @description Method that retrieves the quoteline fieldset from the mdt
     * @return Set<Schema.SObjectField> - returns set of quoteline fields
     */
    Set <Schema.SObjectField> getQuoteLineFieldSet();
    /**
     * @description method to retrieve a list of the Brief Item Fields
     * @return List<SChema.SObjectField> - returns list of briefitem fields
     */
    List<Schema.SObjectField> getBriefItemFieldsList();
}