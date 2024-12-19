/**
 * @Author ATG
 * @description Selector Class for Brief Items Field Tracking Object
 * @Date 10/24/23
 */
public inherited sharing class BriefItemTrackingSelector extends fflib_SObjectSelector implements IBriefItemTrackingSelector{
     /**
     * @description default constructor for selector
     * @return IBriefItemTrackingSelector Interface
     */
    public static IBriefItemTrackingSelector newInstance() {
        return (IBriefItemTrackingSelector) Application.Selector.newInstance(
            Brief_Item_Tracking__mdt.SObjectType
        );
    }

    /**
     * @description override default object type method
     * @return object type metadata
     */
    public Schema.SObjectType getSObjectType(){
        return Brief_Item_Tracking__mdt.SObjectType;
    }


    /**
     * @description This method returns all values of the custom metadata type
     * @return List<Brief_Item_Tracking__mdt> list of mdt values
     */
    public List<Brief_Item_Tracking__mdt> getAllValues(){
        return Brief_Item_Tracking__mdt.getAll().values();
    }

    /**
     * @description this method gets all of the field mappings for the custom metadata type
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField>{
            Brief_Item_Tracking__mdt.BriefItemFieldAPIName__c,
            Brief_Item_Tracking__mdt.Trigger_In_Campaign_Change__c
        };
    }
    /**
     * @description this method returns a Map of each field name and if it should trigger a campaign email
     * @return Map<Schema.SObjectField,Boolean>
     */
    public Map<Schema.SObjectField,Boolean> getAllTrackingFields(){
        Map<Schema.SObjectField,Boolean>  fieldNamesMap = new Map<Schema.SObjectField,Boolean>();
        List<Brief_Item_Tracking__mdt> trackingMetaDataList = Brief_Item_Tracking__mdt.getAll().values();
        SObjectType objType = ((SObject)Type.forName('Brief_Item__c').newInstance()).getSObjectType();
        for(Brief_Item_Tracking__mdt mapping: trackingMetaDataList){
            if(objType.getDescribe().fields.getMap().containsKey(mapping.BriefItemFieldAPIName__c)){
                fieldNamesMap.put(objType.getDescribe().fields.getMap().get(mapping.BriefItemFieldAPIName__c),mapping.Trigger_In_Campaign_Change__c);
            }
        }
        return fieldNamesMap;
    }
}