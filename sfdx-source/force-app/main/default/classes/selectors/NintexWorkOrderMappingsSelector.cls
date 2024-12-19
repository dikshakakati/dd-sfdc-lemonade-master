/**
 * @author Deloitte
 * @date 08/18/2022
 * @description Selector class for Nintex_Work_Order_Mapping__mdt custom metadata.
 */
public inherited sharing class NintexWorkOrderMappingsSelector extends fflib_SObjectSelector implements INintexWorkOrderMappingsSelector {
    /**
     * @description Default constructor for NintexWorkOrderMappingsSelector class.
     * @return INintexWorkOrderMappingsSelector
     */
    public static INintexWorkOrderMappingsSelector newInstance() {
        return (INintexWorkOrderMappingsSelector) Application.Selector.newInstance(
            Nintex_Work_Order_Mapping__mdt.SObjectType
        );
    }

    /**
     * @description It is used for getting Nintex_Work_Order_Mapping__mdt object type.
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Nintex_Work_Order_Mapping__mdt.SObjectType;
    }

    /**
     * @description It is used for getting the fields on Nintex_Work_Order_Mapping__mdt.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Nintex_Work_Order_Mapping__mdt.Nintex_Use_Case__c,
            Nintex_Work_Order_Mapping__mdt.Work_Order_Provisioning_Process__c,
            Nintex_Work_Order_Mapping__mdt.Work_Order_Sub_Type__c,
            Nintex_Work_Order_Mapping__mdt.Work_Order_Type__c
        };
    }

    /**
     * @description It is used to fetch all "Nintex Use Case To Work Order Mapping"
     * custom metadata records.
     * @return List<Nintex_Work_Order_Mapping__mdt>
     */
    public List<Nintex_Work_Order_Mapping__mdt> getAllMappings() {
        return Nintex_Work_Order_Mapping__mdt.getall().values();
    }
}