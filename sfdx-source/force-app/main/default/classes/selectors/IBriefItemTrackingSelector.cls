/**
 * @author ATG
 * @date 10/24/23
 * @description Interface to add selector class methods for the BriefItemTrackingSelectorClass
 */
public interface IBriefItemTrackingSelector extends fflib_ISObjectSelector{
    /**
     * @description Method to get all of the custom metadata records
     * @return List<Brief_Item_Tracking__mdt>
     */
    List<Brief_Item_Tracking__mdt> getAllValues();
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
     * @description this method returns a Map of each field name and if it should trigger a campaign email
     * @return Map<Schema.SObjectField,Boolean>
     */
    Map<Schema.SObjectField,Boolean> getAllTrackingFields();
}