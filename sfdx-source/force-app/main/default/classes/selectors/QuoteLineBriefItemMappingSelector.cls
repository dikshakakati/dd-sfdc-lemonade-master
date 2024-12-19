/**
 * @Author ATG
 * @Date 09/27/2023
 * @description selector class for the Quote Line to BriefItem mapping
 */

public inherited sharing class QuoteLineBriefItemMappingSelector extends fflib_SObjectSelector implements IQuoteLineBriefItemMappingSelector{

    /**
     * @description default constructor for selector
     * @return IQuoteLineBriefItemMappingSelector Interface
     */
    public static IQuoteLineBriefItemMappingSelector newInstance() {
        return (IQuoteLineBriefItemMappingSelector) Application.Selector.newInstance(
            Quote_Line_to_Brief_Item_Mapping__mdt.SObjectType
        );
    }

    /**
     * @description override default object type method
     * @return object type metadata
     */
    public Schema.SObjectType getSObjectType(){
        return Quote_Line_to_Brief_Item_Mapping__mdt.SObjectType;
    }


    /**
     * @description This method returns all values of the custom metadata type
     * @return List<Quote_Line_to_Brief_Item_Mapping__mdt> list of mdt values
     */
    public List<Quote_Line_to_Brief_Item_Mapping__mdt> getAllValues(){
        return Quote_Line_to_Brief_Item_Mapping__mdt.getAll().values();
    }

    /**
     * @description this method gets all of the field mappings for the custom metadata type
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField>{
            Quote_Line_to_Brief_Item_Mapping__mdt.QuoteLineFieldAPIName__c,
            Quote_Line_to_Brief_Item_Mapping__mdt.BriefItemFieldAPIName__c
        };
    }

    /**
     * @description returns set of quote line fields
     * @return Set <Schema.SObjectField>
     */
    public Set <Schema.SObjectField> getQuoteLineFieldSet(){
        Set<Schema.SObjectField> quoteLineFieldSet = new Set<Schema.SObjectField>();
        List<Quote_Line_to_Brief_Item_Mapping__mdt> syncMap = Quote_Line_to_Brief_Item_Mapping__mdt.getAll().values();
        SObjectType objType = ((SObject)Type.forName('SBQQ__QuoteLine__c').newInstance()).getSObjectType();
        for(Quote_Line_to_Brief_Item_Mapping__mdt mapping: syncMap){
            if(objType.getDescribe().fields.getMap().containsKey(mapping.QuoteLineFieldAPIName__c)){
                quoteLineFieldSet.add(objType.getDescribe().fields.getMap().get(mapping.QuoteLineFieldAPIName__c));
            }
        }
        return quoteLineFieldSet;
    }

    /**
     * @description returns a list of briefitem fields
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getBriefItemFieldsList(){
        List<Schema.SObjectField> briefItemFieldsList = new List<Schema.SobjectField>();
        List<Quote_Line_to_Brief_Item_Mapping__mdt> syncMap = Quote_Line_to_Brief_Item_Mapping__mdt.getAll().values();
        SObjectType objType = ((SObject)Type.forName('Brief_Item__c').newInstance()).getSObjectType();
        for(Quote_Line_to_Brief_Item_Mapping__mdt mapping: syncMap){
            if(objType.getDescribe().fields.getMap().containsKey(mapping.BriefItemFieldAPIName__c)){
                briefItemFieldsList.add(objType.getDescribe().fields.getMap().get(mapping.BriefItemFieldAPIName__c));
            }

        }
        return briefItemFieldsList;
    }
}