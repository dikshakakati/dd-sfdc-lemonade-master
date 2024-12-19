/**
 * @author ATG
 * @date 10/03/2023
 * @description selector class for retrieving mapping data from Opportunity to Brief
 */
public inherited sharing class OpportunityToBriefMappingSelector extends fflib_SObjectSelector implements IOpportunityToBriefMappingSelector{
     /**
     * @description default constructor for selector
     * @return IOpportunityToBriefMappingSelector Interface
     */
    public static IOpportunityToBriefMappingSelector newInstance() {
        return (IOpportunityToBriefMappingSelector) Application.Selector.newInstance(
            Opportunity_To_Brief_Item_Mapping__mdt.SObjectType
        );
    }

    /**
     * @description override default object type method
     * @return object type metadata
     */
    public Schema.SObjectType getSObjectType(){
        return Opportunity_To_Brief_Item_Mapping__mdt.SObjectType;
    }


    /**
     * @description This method returns all values of the custom metadata type
     * @return List<Opportunity_To_Brief_Item_Mapping__mdt> list of mdt values
     */
    public List<Opportunity_To_Brief_Item_Mapping__mdt> getAllValues(){
        return Opportunity_To_Brief_Item_Mapping__mdt.getAll().values();
    }

    /**
     * @description this method gets all of the field mappings for the custom metadata type
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField>{
            Opportunity_To_Brief_Item_Mapping__mdt.BriefFieldAPIName__c,
            Opportunity_To_Brief_Item_Mapping__mdt.OpportunityFieldAPIName__c
        };
    }
     /**
     * @description returns a list of Brief fields
     * @return List<String>
     */
    public List<Schema.SObjectField> getBriefFieldsList(){
        List<Schema.SObjectField> briefFieldsList = new List<Schema.SObjectField>();
        List<Opportunity_To_Brief_Item_Mapping__mdt> syncMap = Opportunity_To_Brief_Item_Mapping__mdt.getAll().values();
        SObjectType objType = getSObjectTypeByObjectName('Brief__c');
        for(Opportunity_To_Brief_Item_Mapping__mdt mapping: syncMap){
            if(objType.getDescribe().fields.getMap().containsKey(mapping.BriefFieldAPIName__c)){
                briefFieldsList.add(objType.getDescribe().fields.getMap().get(mapping.BriefFieldAPIName__c));
            }

        }
        return briefFieldsList;
    }

    /**
     * @description returns a set of fields that are being used by the opportunity
     * @return Set<Schemea.SObjectField>
     */
    public Set <Schema.SObjectField> getOpportunityFieldSet(){
        Set<Schema.SObjectField> oppFieldSet = new Set<Schema.SObjectField>();
        List<Opportunity_To_Brief_Item_Mapping__mdt> syncMap = Opportunity_To_Brief_Item_Mapping__mdt.getAll().values();
        SObjectType objType = getSObjectTypeByObjectName('Opportunity');
        for(Opportunity_To_Brief_Item_Mapping__mdt mapping: syncMap){
            if(objType.getDescribe().fields.getMap().containsKey(mapping.OpportunityFieldAPIName__c)){
                oppFieldSet.add(objType.getDescribe().fields.getMap().get(mapping.OpportunityFieldAPIName__c));
            }
        }
        return oppFieldSet;
    }

    /**
     * @description helper method for retrieving SObjectType based on object string name
     * @param objectName
     * @return SObjectType
     */
    private SObjectType getSObjectTypeByObjectName(String objectName){
        return ((SObject)Type.forName(objectName).newInstance()).getSObjectType();
    }
}