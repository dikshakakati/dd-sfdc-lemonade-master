/**
 * @author ATG
 * @date 09/25/2023
 * @description Selector Class for BriefItemToSubscriptionSyncMapping custom metadata
 */
public inherited sharing class BriefItemSubscriptionMappingSelector extends fflib_SObjectSelector implements IBriefItemSubscriptionMappingSelector{
    /**
     * @description default constructor for the class
     * @return IBriefItemSubscriptionMappingSelector - interface of IBriefItemSubscriptionMapping
     */
    public static IBriefItemSubscriptionMappingSelector newInstance() {
        return (IBriefItemSubscriptionMappingSelector) Application.Selector.newInstance(
            Brief_Item_To_Subscription_Sync_Mapping__mdt.SObjectType
        );
    }

     /**
     * @description override default getSObjectType method
     * @return SObjectType - object type of metadata
     */
    public Schema.SObjectType getSObjectType() {
        return Brief_Item_To_Subscription_Sync_Mapping__mdt.SObjectType;
    }

    /**
     * @description This method is for getting all field values for Brief_Item_To_Subscription_Sync_Mapping__mdt
     * @return List<Brief_Item_To_Subscription_Sync_Mapping__mdt> - List of metadata records with values
     */
    public List<Brief_Item_To_Subscription_Sync_Mapping__mdt> getAllValues() {
        return Brief_Item_To_Subscription_Sync_Mapping__mdt.getall().values();
    }

    /**
     * @description This method is for getting the fields on Brief_Item_To_Subscription_Sync_Mapping__mdt
     * @return List<Schema.SObjectField>- Brief_Item_To_Subscription_Sync_Mapping__mdt fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Brief_Item_To_Subscription_Sync_Mapping__mdt.BriefItemFieldAPIName__c,
            Brief_Item_To_Subscription_Sync_Mapping__mdt.SubscriptionFieldAPIName__c
        };
    }
    /**
     * @description this method returns a Map of each field name and if it should trigger a campaign email
     * @return Map<Schema.SObjectField,Boolean>
     */
    public Map<Schema.SObjectField,Boolean> getAllBriefItemFields(){
        Map<Schema.SObjectField,Boolean>  fieldNamesMap = new Map<Schema.SObjectField,Boolean>();
        List<Brief_Item_To_Subscription_Sync_Mapping__mdt> syncMetaDataList = Brief_Item_To_Subscription_Sync_Mapping__mdt.getAll().values();
        SObjectType objType = ((SObject)Type.forName('Brief_Item__c').newInstance()).getSObjectType();
        for(Brief_Item_To_Subscription_Sync_Mapping__mdt mapping: syncMetaDataList){
            if(objType.getDescribe().fields.getMap().containsKey(mapping.BriefItemFieldAPIName__c)){
                fieldNamesMap.put(objType.getDescribe().fields.getMap().get(mapping.BriefItemFieldAPIName__c),true);
            }
        }
        return fieldNamesMap;
    }
}