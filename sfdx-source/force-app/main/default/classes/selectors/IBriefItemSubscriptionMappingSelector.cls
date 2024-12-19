/**
 * @author ATG
 * @date 09/25/2023
 * @description Interface to add Selector class methods
 */
public interface IBriefItemSubscriptionMappingSelector extends fflib_ISObjectSelector{
    /**
     * @description Method fetches all Country Attributes Mapping records
     * @return List<Brief_Item_To_Subscription_Sync_Mapping__mdt> - returns list of metadata records
     */
    List<Brief_Item_To_Subscription_Sync_Mapping__mdt> getAllValues();

    /**
     * @description This method is for getting the fields on Brief_Item_To_Subscription_Sync_Mapping__mdt
     * @return List<Schema.SObjectField>- Brief_Item_To_Subscription_Sync_Mapping__mdt fields
     */
    List<Schema.SObjectField> getSObjectFieldList();
    /**
     * @description this method returns a Map of each field name
     * @return Map<Schema.SObjectField,Boolean>
     */
    Map<Schema.SObjectField,Boolean> getAllBriefItemFields();
}