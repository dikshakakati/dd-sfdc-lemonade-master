/**
 * @description OrderProtocolMappingsSelector Selector class
 */
public inherited sharing class OrderProtocolMappingsSelector extends fflib_SObjectSelector implements IOrderProtocolMappingsSelector {
    /**
     * @description Default constructor for the OrderProtocolMappingsSelector class.
     * @return IOrderProtocolMappingsSelector
     */
    public static IOrderProtocolMappingsSelector newInstance() {
        return (IOrderProtocolMappingsSelector) Application.SELECTOR.newInstance(
            Order_Protocol_Mapping__mdt.SObjectType
        );
    }
    /**
     * @description override default getSObjectType method
     * @return SObjectType - object type
     */
    public Schema.SObjectType getSObjectType() {
        return Order_Protocol_Mapping__mdt.SObjectType;
    }

    /**
     * @description This method is for getting the fields on Work Order
     * @return List<Schema.SObjectField> - MDS Sync Mapping fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Order_Protocol_Mapping__mdt.MasterLabel,
            Order_Protocol_Mapping__mdt.DeveloperName,
            Order_Protocol_Mapping__mdt.Contains__c,
            Order_Protocol_Mapping__mdt.Old_Value__c,
            Order_Protocol_Mapping__mdt.Result__c,
            Order_Protocol_Mapping__mdt.Active__c,
            Order_Protocol_Mapping__mdt.Ignore_Values__c
        };
    }

     /**
    * @description this method is for querying all MDS sync Mappings
    * @return List<Order_Protocol_Mapping__mdt>
    */
    public List<Order_Protocol_Mapping__mdt> getActiveOrderProtocolMappings() {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Active__c = true');
        return (List<Order_Protocol_Mapping__mdt>) Database.query(query.toSOQL());
    }
}
